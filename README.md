# How to use this configuration file?

1. Install necessary packages in command line

```bash
sudo dnf install clash alacritty i3-gaps picom polybar rofi stow arandr google-chrome-stable zsh ranger light feh fcitx5 xinput
```

2. Git clone dotfiles config

```bash
ssh-kgen -t ed25519 -C "997707754@qq.com"
# add the content in ~/.ssh/id_ed25519.pub to github ssh key
mkdir ~/stow
cd stow
git clone git@github.com:GentleTomZerg/.dotfiles.git ~/stow
```

3. Stow the configuration

```bash
stow alacritty/ clash/ i3/ ideavimrc/ polybar/ picom/ rofi/ wiki/ Xresources/ zshrc/
```

4. Clash

- before setting up oh-my-zsh, my zshrc scripts cannot be used to start proxy.
- `clash -f ~/.config/clash/*.yaml`
- then proxy service can be used

5. Install fonts

- go to nerfont websites
- download Jetbrains Mono Nerd Font
- unzip the zip under ~/.local/share/fonts/

6. Now we can use i3wm

7. Shell

- open alacritty
- type zsh in bash
- enter chsh
- zsh will prompt you to install packages which provides chsh
- `sudo chsh -s /path/to/zsh` **Must use sudo**
- logout from i3wm and login again
- now zsh shell is the default shell

8. Install oh-my-zsh

- go to oh-my-zsh paste the download script and execute
- oh-my-zsh will make the .zshrc symlinked by stow as a old version and provide a new version.
- delete the old and new version
- stow zshrc again
- Problems might occur: plugins missings -> google and solve it
- Now, clash can be triggered by `startproxy`

9. Enable clash-dashboard

```bash
git clone git@github.com:Dreamacro/clash-dashboard.git ~/.config/clash/clash-dashboard
cd ~/.config/clash/clash-dashboard/
git checkout gh-pages
```

10. Nvim Config

```bash

git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim
mkdir -p ~/.config/nvim/lua/user
git clone git@github.com:GentleTomZerg/astrovim-config.git ~/.config/nvim/lua/user
nvim

sudo dnf install gcc npm cargo go luarocks python3-pip
```

- install the optional packages astronvim web told(like `bottom`)
- remember to install `gcc` and `g++`, just type g++ in terminal, it will tell you what packages provide usage of `g++`. Then the treesitter will compile without problem.

11. Enabel alacritty theme

```bash
# We use Alacritty's default Linux config directory as our storage location here.
mkdir -p ~/.config/alacritty/themes
git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
```

12. Install lazygit

```bash
sudo dnf copr enable atim/lazygit -y
sudo dnf install lazygit
```

13. Chinese input

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

14. Display

- first use `arandr` to set the monitors. (GUI tool)
- then use `autorandr` to save the current monitors config (`autorandr --save [name]`)
<!-- TODO: -->
- Bug: the i3wm has problems to initialize the monitors display corrently when first enter, it needs a manual refresh.
- Temporal solution:

  I use arandr to customize a laptop left, monitor right config. Let autorandr to save it, in this way, two monitors will have correct display of wallpapers.

  If we put laptop left and monitor right, the first display when we entered i3wm shows the laptop-size wall-paper in the monitor and the monitor-size wall-paper in both laptop and monitor. Now, I suspect it is the problem of `feh` or `i3wm` multiple monitor config rule.

15. Enable RPM free and non-free

```bash
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

16. Rofi

    There are some really nice themes and applets written for rofi, download from here:
    [rofi-collection](https://github.com/adi1090x/rofi)

    Follow the link and setup as instructed. The `i3wm` and `polybar` will use this preconfigured repository.

17. Ranger

    - Enable icons for ranger, follow this [link](https://github.com/alexanderjeurissen/ranger_devicons)
    - stow the config from my .dotfiles

18. Develop Packages

```bash
sudo dnf install fontconfig-devel freetype-devel libX11-xcb libX11-devel libstdc++-static libstdc++-devel
sudo dnf groupinstall "Development Tools" "Development Libraries"
```

# Some useful tools:

- cpufetch
- lsd
- bpytop
- speedtest

# Fedora Dual Boot and Kernel Update

## Switch to New Kernel

- If the kernel is updated, use `grub-customizer` to detect all the new available boot entry.
- Then, use the command `sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg`

## Delete Old Kernels

- Check Installed Kernels

```bash
rpm -qa kernel\* |sort -V
```

- Delete Old Kernels

```bash
## dnf repoquery set negative --latest-limit ##
## as how many old kernels you want keep ##
## IMPORTANT: the --latest-limit depends on the number of kernels you have.
dnf remove $(dnf repoquery --installonly --latest-limit=-2 -q)
```

## Set Max Number of Kernels

- go to `/etc/dnf/dnf.conf`
- change `installonly_limit=$(NUMBER)`
