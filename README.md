# How to use this configuration file?

1. Install necessary packages in command line

```shell
dnf install clash alacritty i3-gaps picom polybar rofi stow arandr google-chrome-stable zsh ranger light feh fcitx5
```

2. Git clone dotfiles config

```shell
ssh-kgen -t ed25519 -C "997707754@qq.com"
# add the content in ~/.ssh/id_ed25519.pub to github ssh key
mkdir ~/stow
cd stow
git clone git@github.com:GentleTomZerg/.dotfiles.git ~/stow
```

3. Stow the configuration

```shell
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

```shell
git clone git@github.com:Dreamacro/clash-dashboard.git ~/.config/clash/clash-dashboard
cd ~/.config/clash/clash-dashboard/
git checkout gh-pages
```

10. Nvim Config

```shell

git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim
mkdir -p ~/.config/nvim/lua/user
git clone git@github.com:GentleTomZerg/astrovim-config.git ~/.config/nvim/lua/user
nvim

sudo dnf install gcc npm cargo go luarocks python3-pip
```

11. Enabel alacritty theme

```shell
# We use Alacritty's default Linux config directory as our storage location here.
mkdir -p ~/.config/alacritty/themes
git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
```

12. Install lazygit

```shell
sudo dnf copr enable atim/lazygit -y
sudo dnf install lazygit
```

13. Chinese input
<!-- TODO: -->

14. Display
