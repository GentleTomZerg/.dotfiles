# How to use .dotfiles repository?

Now this dotfiles configuration has migrated to stow.:happy:

**Usage**:

- install `stow`
- in `HOME` directory, clone all the conents of this repository under `HOME/stow/`
- stow all the directory(`stow $dirname`)

# How does `stow` work?

This repo mainly uses `stow` to manage dotfiles, since initializing git under `HOME` directory is a bad practice, you have to maintain a complex `.gitignore` file. Now, all the dotfiles configurations are under `HOME/stow/`.

For example, the configuration of `alacritty` lies in `HOME/.config/alacritty/alacritty.yml`, now it is put in `HOME/stow/alacritty/.config/alacritty/alacritty.yml`. The command `stow alacritty` will make a symlink `HOME/.config/alacritty` which actually points to the `HOME/stow/alacritty/.config/alacritty/`. Thus, we can initialize a git repository under stow, and all the dotfiles can be managed in a file.

`stow alacritty` used the default settings, it must be executed in `HOME/stow/`, which is the source directory of all the dotfiles, and the target is the parent directory of `HOME/stow/` by default. If different target and source path is needed, see the manual page of `stow`.
