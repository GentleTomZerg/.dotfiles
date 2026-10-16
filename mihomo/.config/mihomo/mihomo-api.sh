#!/bin/bash
# Thin shell facade over the Deno mihomo tool (tools/mihomo/main.ts).
#
# Despite the shebang, this file is *sourced* (from ~/.zshrc and from the
# runbook), so it must run in both bash and zsh and must never call `exit`:
# that would kill the caller's shell. Every wrapper uses `return` and hands the
# tool's exit status back unchanged.
#
# The tool owns the config rendering, the retry loop, the platform check and the
# tweak-state bookkeeping that used to live here; `render`, `start`, `stop` and
# `status` are now subcommands. Only `setproxy`/`unsetproxy` stay literal shell,
# because they must mutate the *caller's* environment, which a subprocess cannot.
#
# Two dual-shell traps that have already bitten:
#   - `path` is a special zsh parameter tied to $PATH: never `read -r path`
#   - zsh arrays are 1-indexed, bash's are 0-indexed: prefer plain scalars
#
# The config dir is *not* set here: the tool derives it from MIHOMO_CONFIG_PATH
# or $HOME/.config/mihomo (see tools/mihomo/src/config.ts), so the facade only
# has to locate the tool itself.

# Service URL used by setproxy; the tool reads the same variable for its checks.
MIHOMO_SERVICE_URL="${MIHOMO_SERVICE_URL:-http://127.0.0.1:7890}"

# Resolve this file's own path, following symlinks. stow links the whole
# mihomo/.config/mihomo directory, and a manual `ln -s` links the file itself.
# zsh exposes the sourced path as ${(%):-%x}, bash as ${BASH_SOURCE[0]}. macOS
# has no `readlink -f`, so follow the links by hand and resolve the final
# directory with `cd -P` (which also normalises /tmp -> /private/tmp).
function _mihomo_api_locate() {
    local self target dir
    # shellcheck disable=SC2296  # zsh's ${(%):-%x}; bash takes the BASH_SOURCE branch
    self="${BASH_SOURCE[0]:-${(%):-%x}}"
    while [ -L "$self" ]; do
        target="$(readlink "$self")"
        case "$target" in
            /*) self="$target" ;;
            *) self="$(dirname "$self")/$target" ;;
        esac
    done
    dir="$(cd -P "$(dirname "$self")" && pwd)"
    # dir = <repo-root>/mihomo/.config/mihomo, so the repo root is three up.
    printf '%s\n' "$(dirname "$(dirname "$(dirname "$dir")")")/tools/mihomo/main.ts"
}
_MIHOMO_API_MAIN="$(_mihomo_api_locate)"

# Forward one subcommand to the tool and pass its exit status through.
#
# Minimal Deno permission set:
#   --allow-read / --allow-write  render reads the template, providers.yaml and
#     the provider caches, then writes provider-tweaks.yaml + the runtime file.
#     The config dir is env/home-derived, so it cannot be pinned to one path
#     here without duplicating the tool's settings logic.
#   --allow-env                   every setting comes from the environment, and
#     Deno.env.toObject() needs the whole-env grant (a scoped list is refused).
#   --allow-run=...               only the binaries the tool actually executes:
#     curl (status), mihomo (render/start), networksetup (macOS DNS), pgrep
#     (process), scutil (macOS DNS check), sudo (privileged steps), uname
#     (platform probe). sudo's own children are not gated by this list.
# --allow-sys and --allow-net are not needed: `uname` and `curl` run as ordinary
# subprocesses, not through Deno's system/network APIs.
function _mihomo_api_run() {
    if [ ! -f "$_MIHOMO_API_MAIN" ]; then
        echo "mihomo: CLI entrypoint not found at $_MIHOMO_API_MAIN" >&2
        return 127
    fi
    command deno run \
        --allow-read \
        --allow-write \
        --allow-env \
        --allow-run=curl,mihomo,networksetup,pgrep,scutil,sudo,uname \
        "$_MIHOMO_API_MAIN" "$@"
}

# Render the runtime config (template + providers.yaml + liftable provider DNS),
# validated by `mihomo -t`. The tool prints where it wrote the file.
function render_config() {
    _mihomo_api_run render
    return $?
}

# Start mihomo: render, cache sudo, point macOS DNS at the virtual IP, launch,
# then gate success on the full status suite.
function startproxy() {
    _mihomo_api_run start
    return $?
}

# Stop mihomo and, on macOS, hand system DNS back to the system.
function stopproxy() {
    _mihomo_api_run stop
    return $?
}

# Verify the running proxy: controller, blocked site, dashboard and system DNS.
function statusproxy() {
    _mihomo_api_run status
    return $?
}

# The two functions that must stay in the caller's shell: exporting here is what
# points tools at the mixed port. They mirror the tool's MIHOMO_SERVICE_URL.
function setproxy() {
    export {http,https,ftp,all}_proxy="$MIHOMO_SERVICE_URL"
    export {HTTP,HTTPS,FTP,ALL}_PROXY="$MIHOMO_SERVICE_URL"
}

function unsetproxy() {
    unset {http,https,ftp,all}_proxy
    unset {HTTP,HTTPS,FTP,ALL}_PROXY
}
