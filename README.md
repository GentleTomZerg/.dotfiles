# How to use this configuration file?

> Man was born free, and he is everywhere in chains

I don't know if we were born free, but I do know we are in chains. To break the chains, we need network proxy to the free world.

This article assumes we have a stable proxy service already. In my scenario, I have an IPhone with shadowrocket installed. If I connect my IPhone and my new laptop into the same local network, then my new laptop could use my IPhone as the proxy. **No More Chains!!!**

Type this to the new laptop terminal, and we are ready to go!

<!-- more -->

```bash
export {http,https,ftp,all}_proxy="http://IPhone_inner_ip:Proxy_port"
export {HTTP,HTTPS,FTP,ALL}_PROXY="http://IPhone_inner_ip:Proxy_port"
# Eg:
export {http,https,ftp,all}_proxy="http://192.168.1.6:1082"
export {HTTP,HTTPS,FTP,ALL}_PROXY="http://192.168.1.6:1082"

# Plugins configuration process needs git
git config --global http.proxy $CLASH_URL
git config --global https.proxy $CLASH_URL
```

# Start Configuration

## Install necessary packages

```bash
# Macos
brew install \
mihomo yq yazi zellij fzf zoxide fd uv neovim direnv fastfetch btop \
starship stow lazygit tldr p7zip lsd \
aerospace raycast wezterm google-chrome homerow hyerkey intellij-idea keycastr wechat \
font-fira-code-nerd-font font-lxgw-wenkai

# Archlinux hyprland
sudo pacman -S \
mihomo yq yazi zellij fzf zoxide fd uv neovim direnv fastfetch btop \
starship stow lazygit tldr p7zip lsd \

sudo pacman -S ttf-firacode-nerd
sudo pacman -S ttf-jetbrains-mono-nerd
sudo pacman -S noto-fonts-cjk
sudo pacman -S noto-fonts-emoji

sudo pacman -S \
wayland hyprland rofi-wayland cliphist waybar pywal hyprpaper hypridle hyprlock slurp grim
```

## Stow the configuration

```bash
ssh-kgen -t ed25519 -C "your_email@xx.com"
# add the content in ~/.ssh/id_ed25519.pub to github ssh key

mkdir ~/stow
cd stow
git clone git@github.com:GentleTomZerg/.dotfiles.git ~/stow

stow clash zshrc ... # Pick the config I need

# Vscode Configurtion
# Different types of vscode has different path to of user settings
cd /path/to/vscode/User/settings/directory
ln -s $HOME/stow/vscode/keybindings.json ./keybindings.json
ln -s $HOME/stow/vscode/settings.json ./settings.json
```

## Migrate to ZSH (Linux Only)

- type zsh in bash
- enter chsh
- zsh will prompt you to install packages which provides chsh
- `sudo chsh -s /path/to/zsh` **Must use sudo**
- now zsh shell is the default shell

## Mihomo

Now, we can use Mihomo on the new laptop!!!

- Enter subscribe url to '$HOME/stow/clash/.config/clash/mihomo.yaml'
- Type `startproxy` in terminal and follow instructions
- Mihomo Dashboard

  ```bash
  # NOTE!!!
  # when mihomo parse the configuration file, it will prefix /$HOME/.config/mihomo to external-ui
  # so, make sure to place the ui gh-pages under directory /$HOME/.config/mihomo
  git clone -b gh-pages git@github.com:MetaCubeX/metacubexd.git /$HOME/.config/mihomo/external-ui
  external-ui: external-ui/Yacd-meta

  ```

## AstroNvim

Just Google it and follow instructions!

## Chinese Input

### Linux

- install `fcitx5`
- install `fcitx5-chinese-addons` or `fcitx5-rime`
- git clone https://github.com/iDvel/rime-ice.git ~/.local/share/rime --depth 1
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

### MacOS

- install `squirrel-app`
- git clone https://github.com/iDvel/rime-ice.git ~/Library/Rime --depth 1
- customize the yaml

```
# squirrel.yaml
# ascii_mode、inline、no_inline、vim_mode 等等设定
# 可参考 /Library/Input Methods/Squirrel.app/Contents/SharedSupport/squirrel.yaml
app_options:
  com.github.wez.wezterm:
    ascii_mode: true
    vim_mode: true

style:
  # 选择皮肤，亮色与暗色主题
  color_scheme: macos_light
  color_scheme_dark: macos_dark

preset_color_schemes:
  macos_light:
    name: Mac仿原生亮色/macos_light
    author: 一方
    back_color: 0xFFFFFF # 候选条背景色，24位色值，16进制，BGR顺序
    border_color: 0xFFFFFF # 边框色
    text_color: 0x424242 # 拼音行文字颜色
    hilited_back_color: 0xD75A00 # 第一候选项背景背景色
    hilited_candidate_text_color: 0xFFFFFF # 第一候选项文字颜色
    hilited_candidate_label_color: 0xFFFFFF # 第一候选项编号颜色
    hilited_comment_text_color: 0x999999 # 注解文字高亮
    hilited_text_color: 0x999999 # 高亮拼音 (需要开启内嵌编码)
    candidate_text_color: 0x3c3c3c # 预选项文字颜色
    comment_text_color: 0x999999 # 拼音等提示文字颜色
    horizontal: true # 水平排列
    text_orientation: horizontal # horizontal | vertical
    inline_preedit: true # 单行显示，false双行显示
    label_color: 0x999999 # 预选栏编号颜色
    candidate_format: "%c\u2005%@" # 用 1/6 em 空格 U+2005 来控制编号 %c 和候选词 %@ 前后的空间。
    font_face: "PingFangSC" # 候选词编号字体
    font_point: 17 # 候选文字大小
    label_font_point: 13 # 候选编号大小
    corner_radius: 5 # 候选条圆角
    hilited_corner_radius: 5 # 高亮圆角
    border_height: 4 # 窗口上下高度
    border_width: 4 # 窗口左右宽度
    border_color_width: 0 #输入条边框宽度
    #label_font_face: "SFCompactText-Regular"  # 候选词编号字体

  macos_dark:
    name: Mac仿原生暗色/macos_dark
    author: 一方
    back_color: 0x252a2e # 候选条背景色，24位色值，16进制，BGR顺序
    border_color: 0x050505 # 边框色
    text_color: 0x424242 # 拼音行文字颜色
    hilited_back_color: 0xD75A00 # 第一候选项背景背景色
    hilited_candidate_text_color: 0xFFFFFF # 第一候选项文字颜色
    hilited_candidate_label_color: 0xFFFFFF # 第一候选项编号颜色
    hilited_comment_text_color: 0x999999 # 注解文字高亮
    hilited_text_color: 0x999999 # 高亮拼音 (需要开启内嵌编码)
    candidate_text_color: 0xe9e9ea # 预选项文字颜色
    comment_text_color: 0x999999 # 拼音等提示文字颜色
    horizontal: true # 水平排列
    text_orientation: horizontal # horizontal | vertical
    inline_preedit: true # 单行显示，false双行显示
    label_color: 0x999999 # 预选栏编号颜色
    candidate_format: "%c\u2005%@" # 用 1/6 em 空格 U+2005 来控制编号 %c 和候选词 %@ 前后的空间。
    font_face: "PingFangSC" # 候选词编号字体
    font_point: 17 # 候选文字大小
    label_font_point: 13 # 候选编号大小
    corner_radius: 5 # 候选条圆角
    hilited_corner_radius: 5 # 高亮圆角
    border_height: 4 # 窗口上下高度
    border_width: 4 # 窗口左右宽度
    border_color_width: 0 #输入条边框宽度
    #label_font_face: "SFCompactText-Regular"  # 候选词编号字体

```

## Rofi (Linux Only)

There are some really nice themes and applets written for rofi, download from here:
[rofi-collection](https://github.com/adi1090x/rofi)

Follow the link and setup as instructed. The `i3wm` and `polybar` will use this preconfigured repository.

## Bluetooth

```bash
sudo systemctl start bluetooth
sudo systemctl enable bluetooth
```

## Kde-Connect (Linux Only)

    To enable kdeconnect, the linux host machine needs to open specified ports and protocol for kdeconnect

    ```bash
    sudo firewall-cmd --permanent --zone=public --add-service=kdeconnect
    7266 sudo firewall-cmd --reload
    7278 sudo firewall-cmd --list-all
    7282 sudo systemctl enable firewalld.service
    7295 systemctl status firewalld
    ```

## SDDM (Linux Only)

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

## Timeshift (Linux Only)

Backup arch system!!!

```bash
sudo pacman -S timeshift
yay -S timeshit autosnap
```

# Hyprland (Linux Only)

- enable wayland mode for electron app -> see: `$HOME/stow/electronflags`

# MacOS

- `Raycast` replace `rofi`
- `Aerospace` as tiling window manager
- `HomeRow` `HyperKey` for mouse less experience
- zsh vi-mode -> copy and paste with system clipboard?
- Remember to disable the <Ctrl-UP/DOWN/LEFT/RIGHT> keys in system settings, or vim can not resize
- Time zone problem: use this `sudo rm /var/db/timed/com.apple.timed.plist`

# New Challenges

Docker Hub is not easy to reach now, we need to set proxy for our docker

```bash
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
    Port 443
    User git
```

## Grub (Linux Only)

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
