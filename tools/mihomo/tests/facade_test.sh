#!/usr/bin/env bash
# Assertions for the mihomo-api.sh shell facade.
#
#   bash tools/mihomo/tests/facade_test.sh
#
# No sudo, no real mihomo, no network and no real config: every forwarding test
# puts a fake `deno` earlier in PATH, so the facade is exercised end to end
# without the tool doing anything. The facade must work when sourced in both
# bash and zsh, so each assertion runs under both.
set -u

repo_root="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
facade="$repo_root/mihomo/.config/mihomo/mihomo-api.sh"
main_ts="$repo_root/tools/mihomo/main.ts"

failures=0
pass() { printf 'ok   - %s\n' "$1"; }
fail() { printf 'FAIL - %s\n' "$1"; failures=$((failures + 1)); }
assert_eq() { # <description> <actual> <expected>
  if [ "$2" = "$3" ]; then pass "$1"; else fail "$1 (expected [$3], got [$2])"; fi
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Write a shell snippet to a file (so the assertions can quote freely) and echo
# its path. Body is read from stdin, so callers use a heredoc.
snippet() { # <name>
  local file="$tmp/$1.sh"
  cat > "$file"
  printf '%s' "$file"
}

# --- fake deno: records argv, prints a marker, exits with a chosen code -----
fake_bin="$tmp/bin"
mkdir -p "$fake_bin"
cat > "$fake_bin/deno" <<'FAKE'
#!/bin/sh
# Stub for the facade's `deno run <perms> <main.ts> <sub>` calls.
last=""
for arg in "$@"; do last="$arg"; done
[ -n "${FAKE_DENO_ARGS_FILE:-}" ] && printf '%s\n' "$@" > "$FAKE_DENO_ARGS_FILE"
[ -n "${FAKE_DENO_STDOUT:-}" ] && printf 'FAKE-STDOUT %s\n' "$last"
printf 'FAKE-STDERR %s\n' "$last" >&2
exit "${FAKE_DENO_EXIT:-0}"
FAKE
chmod +x "$fake_bin/deno"

# --- 1. all six names defined, in both shells -------------------------------
snip="$(snippet names <<SNIP
source '$facade'
for f in startproxy stopproxy statusproxy render_config setproxy unsetproxy; do
  type "\$f" >/dev/null 2>&1 || echo "MISSING \$f"
done
SNIP
)"
for shell in bash zsh; do
  assert_eq "$shell defines all six names" "$("$shell" "$snip")" ""
done

# --- 2. retired helpers and the tweak-state global are gone -----------------
snip="$(snippet retired <<SNIP
source '$facade'
for f in wait_for is_macos; do
  type "\$f" >/dev/null 2>&1 && echo "PRESENT \$f"
done
[ -z "\${MIHOMO_TWEAKS_STATE+x}" ] || echo "PRESENT MIHOMO_TWEAKS_STATE"
SNIP
)"
for shell in bash zsh; do
  assert_eq "$shell exposes no retired helpers" "$("$shell" "$snip")" ""
done

# --- 3. every wrapper forwards its subcommand and passes status through -----
for pair in render_config:render startproxy:start stopproxy:stop statusproxy:status; do
  fn="${pair%%:*}"; sub="${pair##*:}"
  for shell in bash zsh; do
    snip="$(snippet forward <<SNIP
source '$facade'
$fn
SNIP
)"
    args_file="$tmp/args-$shell-$fn"
    out="$(PATH="$fake_bin:$PATH" FAKE_DENO_STDOUT=1 FAKE_DENO_EXIT=7 \
      FAKE_DENO_ARGS_FILE="$args_file" "$shell" "$snip" 2>"$tmp/err")"
    status=$?
    assert_eq "$shell $fn returns the tool's status unchanged" "$status" "7"
    assert_eq "$shell $fn forwards stdout unchanged" "$out" "FAKE-STDOUT $sub"
    assert_eq "$shell $fn forwards stderr unchanged" "$(cat "$tmp/err")" "FAKE-STDERR $sub"
    assert_eq "$shell $fn passes the resolved entrypoint" \
      "$(grep -c -x "$main_ts" "$args_file")" "1"
  done
done

# --- 4. a failing tool writes nothing to the facade's stdout ----------------
for shell in bash zsh; do
  snip="$(snippet failing <<SNIP
source '$facade'
startproxy
SNIP
)"
  out="$(PATH="$fake_bin:$PATH" FAKE_DENO_EXIT=42 "$shell" "$snip" 2>"$tmp/err")"
  status=$?
  assert_eq "$shell returns a non-zero tool status" "$status" "42"
  assert_eq "$shell leaves stdout empty when the tool fails" "$out" ""
done

# --- 5. a missing entrypoint fails on stderr without killing the shell ------
snip="$(snippet missing <<SNIP
source '$facade'
_MIHOMO_API_MAIN=/nonexistent/mihomo/main.ts
render_config
echo "alive:\$?"
SNIP
)"
for shell in bash zsh; do
  out="$("$shell" "$snip" 2>"$tmp/err")"
  assert_eq "$shell survives a missing entrypoint (return, never exit)" \
    "$out" "alive:127"
  if grep -q "not found" "$tmp/err"; then
    pass "$shell reports a missing entrypoint on stderr"
  else
    fail "$shell reports a missing entrypoint on stderr"
  fi
done

# --- 6. the facade resolves the tool through a /tmp symlink -----------------
link="$tmp/mihomo-api-link.sh"
ln -s "$facade" "$link"
for shell in bash zsh; do
  snip="$(snippet symlink <<SNIP
source '$link'
render_config
SNIP
)"
  args_file="$tmp/args-link-$shell"
  PATH="$fake_bin:$PATH" FAKE_DENO_STDOUT=1 FAKE_DENO_EXIT=0 \
    FAKE_DENO_ARGS_FILE="$args_file" "$shell" "$snip" >/dev/null 2>&1
  assert_eq "$shell resolves the tool through a symlink" \
    "$(grep -c -x "$main_ts" "$args_file" 2>/dev/null)" "1"
done

# --- 7. setproxy / unsetproxy mutate the calling shell ----------------------
# `env` is a child process, so its output proves the vars were *exported* into
# the caller's environment rather than merely set as shell-local variables.
proxy_re='^(http|https|ftp|all)_proxy='
set_snip="$(snippet setproxy <<SNIP
source '$facade'
setproxy
env | grep -Ei '$proxy_re' | sort
SNIP
)"
unset_snip="$(snippet unsetproxy <<SNIP
source '$facade'
setproxy
unsetproxy
env | grep -Ei '$proxy_re' | sort
SNIP
)"
url="http://127.0.0.1:4321"
want="$(printf '%s\n' ALL_PROXY FTP_PROXY HTTP_PROXY HTTPS_PROXY all_proxy ftp_proxy http_proxy https_proxy \
  | sed "s|\$|=$url|" | sort)"
for shell in bash zsh; do
  got="$(MIHOMO_SERVICE_URL="$url" "$shell" "$set_snip")"
  assert_eq "$shell setproxy exports the eight proxy vars" "$got" "$want"
  assert_eq "$shell unsetproxy clears them again" "$("$shell" "$unset_snip")" ""
done

# --- report -----------------------------------------------------------------
echo
if [ "$failures" -eq 0 ]; then
  echo "facade_test: all assertions passed"
  exit 0
fi
echo "facade_test: $failures assertion(s) failed"
exit 1
