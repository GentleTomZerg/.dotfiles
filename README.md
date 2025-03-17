---
title: My Linux Configuration
authors:
  - GentleTomZerg
date:
  created: 2025-03-17
  updated: 2025-03-17
categories:
  - Linux
tags:
  - linux
  - dotfiles
---

# How to use this configuration file?

> Man was born free, and he is everywhere in chains

I don't know if we were born free, but I do know we are in chains. To break the chains, we need network proxy to the free world.

This article assumes we have a stable proxy service already. In my scenario, I have an IPhone with shadowrocket installed. If I connect my IPhone and my new laptop into the same local network, then my new laptop could use my IPhone as the proxy.**The Chains break!!!**

Type this to the new laptop terminal, and we are ready to go!

<!-- more -->

```bash
export {http,https,ftp,all}_proxy="http://IPhone_inner_ip:Proxy_port"
export {HTTP,HTTPS,FTP,ALL}_PROXY="http://IPhone_inner_ip:Proxy_port"
# Eg:
export {http,https,ftp,all}_proxy="http://192.168.1.6:1082"
export {HTTP,HTTPS,FTP,ALL}_PROXY="http://192.168.1.6:1082"
```

## New Challenges

Docker Hub is not easy to reach now, we need to set proxy for our docker

```shell
# /etc/docker/daemon.json
mkdir /etc/docker
echo '{
  "proxies": {
    "http-proxy": "http://127.0.0.1:7890",
    "https-proxy": "https://127.0.0.1:7890"
  }
}' | sudo tee /etc/docker/daemon.json > /dev/null
```

```bash
# ~/.ssh/config
Host github.com
  Hostname ssh.github.com
  User git
  Port 443
```

## Start Configuration

1. Install necessary packages

```bash
sudo pacman -S \
clash kitty i3-gaps picom polybar rofi stow arandr google-chrome-stable zsh yazi light feh fcitx5 xinput docker \
lazygit \
neovim \
zsh-autosuggestions \
zsh-syntax-highlighting \
zsh-theme-powerlevel10k-git \
zsh-theme-powerlevel10k-git-debug \

# For terminal and polybar
sudo pacman -S ttf-firacode-nerd
sudo pacman -S ttf-jetbrains-mono-nerd

# For AUR Google-Chrome
sudo pacman -S noto-fonts-cjk
sudo pacman -S noto-fonts-emoji

# For clash-meta
yay -S mihomo
```

2. Stow the configuration

```bash
ssh-kgen -t ed25519 -C "997707754@qq.com"
# add the content in ~/.ssh/id_ed25519.pub to github ssh key
mkdir ~/stow
cd stow
git clone git@github.com:GentleTomZerg/.dotfiles.git ~/stow

stow clash i3 ideavimrc kitty neovim picom polybar README.md rofi tools vscode Xmodmap Xresources yazi zshrc

# Vscode Configurtion
# Different types of vscode has different path to of user settings
cd /path/to/vscode/User/settings/directory
ln -s $HOME/stow/vscode/keybindings.json ./keybindings.json
ln -s $HOME/stow/vscode/settings.json ./settings.json
```

3. Migrate to ZSH

- type zsh in bash
- enter chsh
- zsh will prompt you to install packages which provides chsh
- `sudo chsh -s /path/to/zsh` **Must use sudo**
- logout from i3wm and login again
- now zsh shell is the default shell

4. Install oh-my-zsh

- go to oh-my-zsh paste the download script and execute
- oh-my-zsh will make the .zshrc symlinked by stow as a old version and provide a new version.
- delete the old and new version
- stow zshrc again

5. Clash / Mihomo

   Now, we can use Mihomo on the new laptop!!!

- ~~Add proxy subscribe url to /stow/clash/.config/clash/urls.txt~~
- ~~Type `updateproxy` in terminal and follow instructions~~
- ~~Type `startproxy` in terminal and follow instructions~~
- ~~Clash-Dashboard~~
- Enter subscribe url to '$HOME/stow/clash/.config/clash/mihomo.yaml'
- Type `startproxy` in terminal and follow instructions
- Mihomo Dashboard

  ```bash
  git clone -b gh-pages git@github.com:MetaCubeX/metacubexd.git
  ```

6. AstroNvim
   Just Google it and follow instructions!

7. Chinese input

- install `fcitx5`
- install `fcitx5-chinese-addons`
- open fcitx5 config, add pinyin
- reboot
- add the following code to /etc/environment and login again

  ```bash
  GTK_IM_MODULE=fcitx
  QT_IM_MODULE=fcitx
  XMODIFIERS=@im=fcitx
  SDL_IM_MODULE=fcitx
  GLFW_IM_MODULE=ibus
  ```

- Theme: follow this [link](https://github.com/hosxy/Fcitx5-Material-Color). Remember to restart the fcitx5 after changing the theme.

- Remember to **Enable Cloud Pinyin** in fcitx5-config
- Dictionary: Follow the link [fcitx5-pinyin-zhwiki](https://github.com/felixonmars/fcitx5-pinyin-zhwiki) and [mw2fcitx](https://github.com/outloudvi/mw2fcitx)

8. Display

- first use `arandr` to set the monitors. (GUI tool)
- then use `autorandr` to save the current monitors config (`autorandr --save [name]`)
<!-- TODO: -->
- Bug: the i3wm has problems to initialize the monitors display corrently when first enter, it needs a manual refresh.
- Temporal solution:

  I use arandr to customize a laptop left, monitor right config. Let autorandr to save it, in this way, two monitors will have correct display of wallpapers.

  If we put laptop left and monitor right, the first display when we entered i3wm shows the laptop-size wall-paper in the monitor and the monitor-size wall-paper in both laptop and monitor. Now, I suspect it is the problem of `feh` or `i3wm` multiple monitor config rule.

- **We might face with complex conditions when switch between different monitors. The best way is to use `arandr`.**

  - Use arandr to generate a basic display shell script and make modifications
  - Change the refresh rate: `--rate 144.00`
  - write script to let the script execute when start up

9. Rofi

   There are some really nice themes and applets written for rofi, download from here:
   [rofi-collection](https://github.com/adi1090x/rofi)

   Follow the link and setup as instructed. The `i3wm` and `polybar` will use this preconfigured repository.

10. Bluetooth

    ```bash
    sudo systemctl start bluetooth
    sudo systemctl enable bluetooth
    ```

11. Kde-Connect

    To enable kdeconnect, the linux host machine needs to open specified ports and protocol for kdeconnect

    ```bash
    sudo firewall-cmd --permanent --zone=public --add-service=kdeconnect
    7266 sudo firewall-cmd --reload
    7278 sudo firewall-cmd --list-all
    7282 sudo systemctl enable firewalld.service
    7295 systemctl status firewalld
    ```

# Grub

We can config grub under the path /etc/default/grub
Below is a configuration example.

- Not shown boot log: add quiet in GRUB_CMDLINE_LINUX_DEFAULT
- Keyboard Issue of Xiaoxin: add i8042.dumbkbd

```bash

# GRUB boot loader configuration

GRUB_DEFAULT="0"
GRUB_TIMEOUT="5"
GRUB_DISTRIBUTOR="EndeavourOS"
GRUB_CMDLINE_LINUX_DEFAULT="nowatchdog nvme_load=YES loglevel=3 i8042.dumbkbd"
# GRUB_CMDLINE_LINUX="rhgb quiet i8042.dumbkbd"

# Preload both GPT and MBR modules so that they are not missed
GRUB_PRELOAD_MODULES="part_gpt part_msdos"

# Uncomment to enable booting from LUKS encrypted devices
#GRUB_ENABLE_CRYPTODISK="y"

# Set to 'countdown' or 'hidden' to change timeout behavior,
# press ESC key to display menu.
GRUB_TIMEOUT_STYLE="menu"

# Uncomment to use basic console
GRUB_TERMINAL_INPUT="console"

# Uncomment to disable graphical terminal
#GRUB_TERMINAL_OUTPUT="console"

# The resolution used on graphical terminal
# note that you can use only modes which your graphic card supports via VBE
# you can see them in real GRUB with the command `videoinfo'
GRUB_GFXMODE="auto"

# Uncomment to allow the kernel use the same resolution used by grub
GRUB_GFXPAYLOAD_LINUX="keep"

# Uncomment if you want GRUB to pass to the Linux kernel the old parameter
# format "root=/dev/xxx" instead of "root=/dev/disk/by-uuid/xxx"
#GRUB_DISABLE_LINUX_UUID="true"

# Uncomment to disable generation of recovery mode menu entries
GRUB_DISABLE_RECOVERY="true"

# Uncomment and set to the desired menu colors.  Used by normal and wallpaper
# modes only.  Entries specified as foreground/background.
#GRUB_COLOR_NORMAL="light-blue/black"
#GRUB_COLOR_HIGHLIGHT="light-cyan/blue"

# Uncomment one of them for the gfx desired, a image background or a gfxtheme
GRUB_BACKGROUND="/usr/share/endeavouros/splash.png"
#GRUB_THEME="/path/to/gfxtheme"

# Uncomment to get a beep at GRUB start
#GRUB_INIT_TUNE="480 440 1"

# Uncomment to make GRUB remember the last selection. This requires
# setting 'GRUB_DEFAULT=saved' above.
#GRUB_SAVEDEFAULT="true"

# Uncomment to disable submenus in boot menu
GRUB_DISABLE_SUBMENU="false"

# Probing for other operating systems is disabled for security reasons. Read
# documentation on GRUB_DISABLE_OS_PROBER, if still want to enable this
# functionality install os-prober and uncomment to detect and include other
# operating systems.
GRUB_DISABLE_OS_PROBER="false"
```

# SDDM

Migrate from `lightdm` to `sddm`

- sddm and theme

```bash
pacman -S sddm
yay -S where-is-my-sddm-theme
```

- modify sddm configuration file

```bash
vim /etc/sddm.conf.d/kde_settings.conf
[Theme]
Current=where_is_my_sddm_theme
```

- enable and start sddm

```bash
systemctl stop lightdm.service
systemctl enable sddm.service
systemctl start sddm.service
```

# Timeshift

Backup arch system!!!

```bash
sudo pacman -S timeshift
yay -S timeshit autosnap
```

# Some useful tools:

- cpufetch
- lsd
- bpytop
- speedtest
- auto-cpufreq

# Hyprland

```bash

sudo pacman -S \
wayland hyprland rofi-wayland cliphist waybar pywal hyprpaper hypridle hyprlock slurp grim
```

- enable wayland mode for electron app -> see: `$HOME/stow/electronflags`
- glaze problem
- practice lazygit
- lsp format file, can it have a template? or only change the modified lines
- learn what oh my zsh is, and what starship is, how to enhance zsh speed
