# Provisioning Runbook

> This runbook provisions a new **macOS** or **Arch-family Linux** machine from this repo — installs packages, stows dotfiles, and configures the system. It assumes a stable proxy service (e.g. an iPhone running Shadowrocket) reachable on the same LAN, which is used to bootstrap the network before the real proxy (mihomo) is up.
>
> **Agent, read this before starting:**
> - Work top to bottom. Skip the platform branch you are not on (each step is tagged `macOS` or `Arch`).
> - **GATE** — stop and ask the human for a value you cannot invent, verify it, then resume. Nothing secret is stored in this repo.
> - **CHECK** — a command ending every step; it must pass before the next step. On failure: stop, report, ask.
> - **⚠ NOT idempotent** — run exactly once. On resume, ask the human whether it already ran.
> - **Resume protocol** — see the bottom of this file.

---

## Phase 0 — Preflight

### 0.1 Detect the platform

```bash
# macOS:
sw_vers
# Arch:
grep '^ID=' /etc/os-release
```

**CHECK** — you know which platform this is. Note it; you will skip the other platform's branches throughout.

### 0.2 Bootstrap the network — GATE

> **GATE — ask the human for the proxy URL** (the iPhone-as-proxy trick: `http://<iPhone_inner_ip>:<port>`). Verify it responds before continuing.

```bash
export {http,https,ftp,all}_proxy="$PROXY_URL"
export {HTTP,HTTPS,FTP,ALL}_PROXY="$PROXY_URL"
curl -fsS https://github.com >/dev/null && echo "network ok"
```

**CHECK** — the curl above succeeds. If not, the URL was wrong or the iPhone is not on this LAN: report, ask, resume at 0.2.

---

## Phase 1 — Packages

### 1.1 macOS — Homebrew packages

> Precondition: Homebrew + Xcode Command Line Tools installed (follow brew.sh if not).

```bash
# Formulae (no --cask)
brew install mihomo yq yazi zellij fzf zoxide fd uv neovim direnv fastfetch \
  btop starship stow lazygit tlrc p7zip lsd

# Casks (require --cask)
brew install --cask raycast wezterm google-chrome homerow hyperkey \
  intellij-idea keycastr wechat font-fira-code-nerd-font font-lxgw-wenkai

# AeroSpace ships in a third-party tap (auto-tapped by the qualified name)
brew install --cask nikitabobko/tap/aerospace

# OPTIONAL — yazi preview/archive tooling (recommended by yazi docs)
brew install ffmpeg-full sevenzip jq poppler fd ripgrep fzf zoxide resvg \
  imagemagick-full font-symbols-only-nerd-font
brew link ffmpeg-full imagemagick-full -f --overwrite   # both are keg-only
```

**CHECK** —

```bash
for f in mihomo yq yazi zellij fzf zoxide fd uv neovim direnv fastfetch \
         btop starship stow lazygit tlrc p7zip lsd; do
  brew list --versions "$f" >/dev/null 2>&1 && echo "OK   $f" || echo "MISS $f"
done
for c in raycast wezterm google-chrome homerow hyperkey intellij-idea \
         keycastr wechat font-fira-code-nerd-font font-lxgw-wenkai aerospace; do
  brew list --cask --versions "$c" >/dev/null 2>&1 && echo "OK   $c" || echo "MISS $c"
done
```

Every name must print `OK`. (If `tldr` was ever installed, `brew uninstall tldr` first — it blocks `tlrc`'s binary link.)

### 1.2 Arch — pacman + AUR packages

> Precondition: an AUR helper. EndeavourOS ships `yay` — use `yay` below; substitute your own helper if different.

```bash
# Official repos (extra)
sudo pacman -S \
  go-yq yazi zellij fzf zoxide fd uv neovim direnv fastfetch btop \
  starship stow lazygit tldr 7zip unzip lsd

# go-yq is mikefarah's Go yq (installs the `yq` binary) — the repo's startproxy
# renders config with mikefarah yq syntax, so the Python `yq` wrapper will not do.

sudo pacman -S ttf-firacode-nerd ttf-jetbrains-mono-nerd noto-fonts-cjk noto-fonts-emoji

sudo pacman -S \
  wayland hyprland rofi cliphist waybar hyprpaper hypridle hyprlock slurp grim

# AUR
yay -S mihomo
yay -S python-pywal16
```

**CHECK** —

```bash
pacman -Q go-yq yazi zellij fzf zoxide fd uv neovim direnv fastfetch btop \
  starship stow lazygit tldr 7zip unzip lsd \
  ttf-firacode-nerd ttf-jetbrains-mono-nerd noto-fonts-cjk noto-fonts-emoji \
  wayland hyprland rofi cliphist waybar hyprpaper hypridle hyprlock slurp grim
# AUR-only installs must show as "local":
pacman -Qm | grep -E '^(mihomo|python-pywal16) '
```

Every package must print without error.

---

## Phase 2 — Dotfiles

### 2.1 SSH key — GATE

> **GATE — ask the human for the SSH email address** (e.g. `name@example.com`). Generate the key, then ask the human to add the public key at <https://github.com/settings/ssh/new> and **wait until they confirm** before continuing.

```bash
ssh-keygen -t ed25519 -C "$SSH_EMAIL" -N ""   # ⚠ NOT idempotent — refuses to overwrite; on resume, reuse the existing key
cat ~/.ssh/id_ed25519.pub                     # give this to the human for GitHub
```

**CHECK** — after the human confirms the key is on GitHub:

```bash
ssh -T -o StrictHostKeyChecking=accept-new git@github.com 2>&1 | grep -q "successfully authenticated" && echo "ssh ok"
```

### 2.2 Clone the repo and stow

```bash
mkdir -p ~/stow
git clone git@github.com:GentleTomZerg/.dotfiles.git ~/stow
cd ~/stow
stow aerospace dunst electronflags ghostty hyprland i3 ideavimrc kitty \
  mihomo neovim polybar raycast rofi sioyek stardict starship surfingkeys \
  tmux tmuxifier waybar wezterm yazi zshrc
```

> Cross-platform packages are inert on the other OS (e.g. `aerospace` on Arch, `hyprland` on macOS) — stow still succeeds; that is expected. If the SSH clone hangs, GitHub's port 22 may be blocked — apply the ssh-port-443 config in [7.3](#73-both--github-over-ssh-port-443) and retry the clone.

**CHECK** —

```bash
for f in ~/.zshrc ~/.config/mihomo/mihomo.yaml ~/.config/nvim ~/.config/rofi \
         ~/.config/starship.toml ~/.tmux.conf ~/.config/yazi ~/.wezterm.lua; do
  test -e "$f" && echo "OK   $f" || echo "MISS $f"
done
```

### 2.3 Vscode settings symlinks

> VS Code's user settings live outside the stow layout, so they are symlinked per platform (VS Code only; variant editors like Cursor are out of scope).

```bash
# macOS:
VDIR="$HOME/Library/Application Support/Code/User"
# Arch:
VDIR="$HOME/.config/Code/User"

mkdir -p "$VDIR"
ln -sfn ~/stow/vscode/settings.json "$VDIR/settings.json"
ln -sfn ~/stow/vscode/keybindings.json "$VDIR/keybindings.json"
```

**CHECK** —

```bash
readlink "$VDIR/settings.json" && readlink "$VDIR/keybindings.json"
```

Both must resolve to `~/stow/vscode/…` symlinks.

### 2.4 Neovim / AstroNvim bootstrap

> The stowed `neovim` package **is** the whole AstroNvim v4+ user config (lazy.nvim-managed, pinned to AstroNvim ^6, needs Neovim 0.11+ — the Phase 1 installs satisfy this). One headless run installs lazy.nvim + AstroNvim + all plugins. Needs network (the bootstrap proxy covers it).

```bash
nvim --headless -c 'quitall'
```

**CHECK** —

```bash
test -f ~/.config/nvim/lazy-lock.json && echo "neovim bootstrapped"
nvim --version | head -1
```

---

## Phase 3 — Shell

### 3.1 macOS — zsh is already the default

**CHECK** — `echo $SHELL` ends in `zsh`. (If not, `chsh -s /bin/zsh`.)

### 3.2 Arch — migrate the default shell to zsh

```bash
sudo pacman -S zsh   # if not already installed
sudo chsh -s /usr/bin/zsh "$USER"
```

> Takes effect at the next login. The agent can keep working in the current shell — when the proxy phase needs the mihomo helper functions, source them directly: `source ~/.config/mihomo/mihomo-api.sh`.

**CHECK** —

```bash
getent passwd "$USER" | cut -d: -f7   # expect /usr/bin/zsh
```

### 3.3 macOS — vi-mode clipboard note

zsh vi-mode is configured in `zshrc/.zshrc`; in the macOS terminal, copy/paste use ⌘C / ⌘V (system clipboard). No action needed.

---

## Phase 4 — Proxy (mihomo)

> The stowed `mihomo` package is the source of truth: `mihomo.yaml` is a shareable template (empty `proxy-providers`, `include-all` groups, TUN + DNS), and the real subscription lives in the **gitignored** `providers.yaml`. `startproxy` deep-merges the two via `yq` into `mihomo_runtime.yaml` and launches mihomo.

### 4.1 Configure the subscription — GATE

> **GATE — ask the human for the mihomo subscription URL** (the airport's subscribe link — it carries a personal token). It is written only to `providers.yaml`, which is gitignored: never commit it, never echo it into the runbook log beyond this step.

```bash
if [[ ! -f ~/.config/mihomo/providers.yaml ]]; then
  cp ~/.config/mihomo/providers.template.yaml ~/.config/mihomo/providers.yaml
fi
# Replace <YOUR_SUBSCRIPTION_URL> in the e-ix block's url: line with the real URL:
sed -i "s|<YOUR_SUBSCRIPTION_URL>|$SUB_URL|" ~/.config/mihomo/providers.yaml
```

**CHECK** —

```bash
yq '.proxy-providers | keys' ~/.config/mihomo/providers.yaml
grep -q '<YOUR_SUBSCRIPTION_URL>' ~/.config/mihomo/providers.yaml \
  && echo "placeholder still present!" || echo "providers.yaml ok"
```

The first command lists your provider(s); the second must print `providers.yaml ok`.

### 4.2 Start the proxy

```bash
source ~/.config/mihomo/mihomo-api.sh   # already auto-sourced by .zshrc in zsh; harmless to repeat
pgrep -x mihomo >/dev/null || startproxy
```

> `startproxy` will prompt for the sudo password (human types it), renders the runtime config, and on macOS points the system DNS at mihomo's virtual IP (198.18.0.2).

**CHECK** — all of:

```bash
pgrep -x mihomo && echo "process ok"
curl -fsS -x http://127.0.0.1:7890 https://www.youtube.com >/dev/null && echo "proxy ok"
curl -fsS -o /dev/null http://127.0.0.1:9090/ui/ && echo "dashboard ok"
# macOS only:
scutil --dns | grep -q 198.18.0.2 && echo "dns ok"
```

### 4.3 Retire the bootstrap proxy

> The iPhone proxy was a stopgap; mihomo now owns proxying (TUN + port 7890).

```bash
unsetproxy
```

**CHECK** —

```bash
env | grep -i proxy || echo "no proxy env vars set"
```

---

## Phase 5 — Input

### 5.1 macOS — Squirrel + rime-ice

```bash
brew install --cask squirrel-app
```

Then (human GUI): System Settings → Keyboard → Input Sources → **+** → 中文 → **鼠鬚管**, and switch to it from the input-menu (ㄓ) icon.

Deploy rime-ice into the Squirrel user dir:

```bash
curl -fL -o /tmp/rime-ice.zip https://github.com/iDvel/rime-ice/releases/latest/download/full.zip
[[ -d ~/Library/Rime ]] && mv ~/Library/Rime ~/Library/Rime.bak.$(date +%s)
mkdir -p ~/Library/Rime
unzip -o /tmp/rime-ice.zip -d ~/Library/Rime
```

Then (human GUI): Squirrel menu-bar icon → **重新部署 (Deploy)**.

> Theme is personal config — rime-ice ships its own `squirrel.yaml`; further theming is out of this runbook's scope.

**CHECK** —

```bash
brew list --cask squirrel-app >/dev/null && echo "squirrel installed"
ls ~/Library/Rime | head
test -n "$(ls -A ~/Library/Rime/build 2>/dev/null)" && echo "deployed" || echo "not deployed yet"
```

### 5.2 Arch — fcitx5 + rime-ice

```bash
sudo pacman -S fcitx5-im fcitx5-chinese-addons fcitx5-rime
```

Set the IM environment variables (X11 / Xwayland apps; native Wayland uses `text-input` automatically — the vars still help Xwayland apps like VS Code):

```bash
sudo tee /etc/environment >/dev/null <<'EOF'
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=ibus
EOF
```

Deploy rime-ice into fcitx5-rime's user dir:

```bash
curl -fL -o /tmp/rime-ice.zip https://github.com/iDvel/rime-ice/releases/latest/download/full.zip
[[ -d ~/.local/share/fcitx5/rime ]] && mv ~/.local/share/fcitx5/rime ~/.local/share/fcitx5/rime.bak.$(date +%s)
mkdir -p ~/.local/share/fcitx5/rime
unzip -o /tmp/rime-ice.zip -d ~/.local/share/fcitx5/rime
fcitx5 -rd   # restart fcitx5
```

> Env vars take effect at the next login. Optional extras (human): enable **Cloud Pinyin** in `fcitx5-configtool`; add the zhwiki dictionary ([fcitx5-pinyin-zhwiki](https://github.com/felixonmars/fcitx5-pinyin-zhwiki)).

**CHECK** —

```bash
fcitx5-diagnose | grep -iE 'GTK_IM_MODULE|QT_IM_MODULE|XMODIFIERS' | head
ls ~/.local/share/fcitx5/rime | head
```

And the human confirms: **Ctrl+Space** toggles pinyin input in an app.

---

## Phase 6 — Desktop

### 6.1 Arch — rofi-collection themes

> The repo's stowed `rofi` config is a minimal base; the i3 config binds `$mod+d` to the collection's launcher (`launchers/type-6`, powermenu `type-5`), so install the adi1090x collection. Its `setup.sh` **moves any existing `~/.config/rofi` aside** to `~/.config/rofi.$USER` (the stowed config is preserved there, not deleted).

```bash
[[ -d /tmp/rofi ]] && rm -rf /tmp/rofi
git clone --depth=1 https://github.com/adi1090x/rofi.git /tmp/rofi
cd /tmp/rofi && chmod +x setup.sh && ./setup.sh
```

**CHECK** —

```bash
test -f ~/.config/rofi/config.rasi && echo "collection installed"
ls -d ~/.config/rofi.* 2>/dev/null   # the stowed config's backup (if it was stowed)
```

### 6.2 Arch — Bluetooth

```bash
sudo pacman -S bluez bluez-utils
sudo systemctl enable --now bluetooth
```

> Pairing devices is interactive — `bluetoothctl` (power on, scan, pair, trust, connect) or the desktop's Bluetooth UI, human-driven.

**CHECK** —

```bash
systemctl is-enabled bluetooth
rfkill list bluetooth   # expect: Soft blocked: no
```

### 6.3 Arch — KDE-Connect firewall

```bash
sudo pacman -S kdeconnect   # if not already installed
sudo firewall-cmd --permanent --zone=public --add-service=kdeconnect
sudo firewall-cmd --reload
sudo systemctl enable --now firewalld.service
```

> The built-in `kdeconnect` firewalld service opens exactly the dynamic range TCP+UDP 1714–1764.

**CHECK** —

```bash
sudo firewall-cmd --permanent --list-services | tr ' ' '\n' | grep -x kdeconnect
systemctl is-enabled firewalld
```

### 6.4 Arch — SDDM display manager

```bash
sudo pacman -S sddm
yay -S where-is-my-sddm-theme-git
sudo tee /etc/sddm.conf.d/kde_settings.conf >/dev/null <<'EOF'
[Theme]
Current=where_is_my_sddm_theme
EOF
sudo systemctl stop lightdm.service   # only if migrating from lightdm
sudo systemctl enable --now sddm.service
```

**CHECK** —

```bash
systemctl is-enabled sddm
ls /usr/share/sddm/themes/ | grep where_is_my_sddm
grep -A1 '^\[Theme\]' /etc/sddm.conf.d/kde_settings.conf
```

### 6.5 Arch — Hyprland / Electron apps on Wayland

> The `electronflags` package (stowed in Phase 2) makes Electron apps run on Wayland: `chrome-flags.conf`, `code-flags.conf`, `spotify-launcher.conf` carry `--ozone-platform=wayland --enable-wayland-ime`. The `waybar` package shows mihomo status via `check_mihomo.sh`.

**CHECK** —

```bash
test -f ~/.config/chrome-flags.conf && echo "electron flags stowed"
grep -h 'ozone-platform' ~/.config/*flags.conf 2>/dev/null
```

### 6.6 macOS — app notes

- **Raycast** replaces Rofi; its stowed scripts (`raycast/.config/raycast/scripts/enable-proxy.sh` — "Go Abroad") toggle the system proxy to mihomo.
- **AeroSpace** is the tiling window manager (`~/.aerospace.toml` stowed).
- **HomeRow + HyperKey** for mouse-less operation.
- Human GUI: disable the **Ctrl+Arrow** Mission-Control shortcuts in System Settings → Keyboard → Keyboard Shortcuts, so vim can resize panes.

**CHECK** —

```bash
brew list --cask raycast aerospace homerow hyperkey >/dev/null && echo "desktop apps installed"
test -f ~/.aerospace.toml && echo "aerospace config stowed"
```

---

## Phase 7 — System-level

### 7.1 Arch — GRUB

> The main config must be **regenerated** after any `/etc/default/grub` edit — this is what makes kernel flags take effect.

```bash
# Kernel flags — adjust for your machine (i8042.dumbkbd is for Xiaoxin/Lenovo keyboards)
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="nowatchdog nvme_load=YES loglevel=3 i8042.dumbkbd"/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg   # REQUIRED after any /etc/default/grub edit
```

> Dual-booting? `sudo pacman -S os-prober`, mount the other OS, re-run `grub-mkconfig`. Optional with Timeshift on btrfs: `grub-btrfs` adds snapshot entries to the boot menu.

**CHECK** —

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg 2>&1 | grep -q 'Found linux image' && echo "grub config regenerated"
grep -c 'menuentry' /boot/grub/grub.cfg
```

### 7.2 Linux — Docker proxy (if Docker is installed)

> Docker is not installed by this runbook; this step applies only if the human uses Docker.

```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json >/dev/null <<'EOF'
{
  "proxies": {
    "http-proxy": "http://127.0.0.1:7890",
    "https-proxy": "http://127.0.0.1:7890"
  }
}
EOF
sudo systemctl restart docker
```

**CHECK** —

```bash
docker info 2>/dev/null | grep -A3 'HTTP Proxy'   # expect 127.0.0.1:7890
```

### 7.3 Both — GitHub over SSH port 443

> Fix for blocked port 22 (also the fallback for a hanging Phase 2.2 clone).

```bash
mkdir -p ~/.ssh
if ! grep -q 'Host github.com' ~/.ssh/config 2>/dev/null; then
  cat >> ~/.ssh/config <<'EOF'
Host github.com
    Hostname ssh.github.com
    Port 443
    User git
EOF
fi
```

**CHECK** —

```bash
ssh -T -o ConnectTimeout=10 git@github.com 2>&1 | grep -q "successfully authenticated" && echo "ssh 443 ok"
```

### 7.4 macOS — timezone fix

> Only needed if the timezone does not persist across reboots.

```bash
sudo rm -f /var/db/timed/com.apple.timed.plist
```

**CHECK** — `test ! -e /var/db/timed/com.apple.timed.plist && echo "removed"`.

### 7.5 Arch — Timeshift backups

```bash
sudo pacman -S timeshift
sudo systemctl enable --now cronie.service   # hard dependency — scheduled snapshots need it
yay -S timeshift-autosnap
```

> `timeshift-autosnap` adds a pacman hook that snapshots before/after every package transaction. First snapshot: `sudo timeshift --create` (human chooses the schedule in the GUI).

**CHECK** —

```bash
pacman -Q timeshift timeshift-autosnap
systemctl is-enabled cronie
ls /etc/pacman.d/hooks/ | grep -i timeshift
```

---

## Phase 8 — Verify

### 8.1 Reboot — GATE

> **GATE — ask the human to reboot the machine and confirm when it is back up.** System-level changes (GRUB flags, DNS, enabled services, IM env vars) only take effect after this.

### 8.2 Smoke checks

```bash
echo "shell:  $SHELL"                                            # expect */zsh
pgrep -x mihomo >/dev/null || startproxy                         # mihomo starts manually after boot
curl -fsS -x http://127.0.0.1:7890 https://www.youtube.com >/dev/null && echo "proxy: ok"
# Arch only:
systemctl is-enabled bluetooth sddm cronie firewalld             # expect enabled ×4
# macOS only:
test -f /var/db/timed/com.apple.timed.plist 2>/dev/null || echo "timezone plist: removed"
test -L ~/.zshrc && test -L ~/.config/nvim && echo "dotfiles: ok"
```

**CHECK** — every line prints the expected value. The human additionally confirms: **Ctrl+Space** toggles pinyin; Wi-Fi/Bluetooth connect; the display manager shows the theme; apps open.

---

## Resume protocol

1. Re-run the **last failed CHECK** first.
2. If it now passes, continue forward from there. If not, re-run the step that precedes it.
3. Skip all already-passed CHECKs. Every step is idempotent except those marked **⚠ NOT idempotent** — for those, ask the human whether it already ran.
4. GATEs are cheap to re-ask — the human would rather confirm a value than debug a wrong one.
