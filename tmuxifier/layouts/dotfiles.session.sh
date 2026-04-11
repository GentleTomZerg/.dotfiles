# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.
session_root "$HOME/stow"

# Create session with specified name if it does not already exist. If no
# argument is given, session name will be based on layout file name.
if initialize_session "dotfiles"; then
  window_root "$HOME/stow"
  new_window "stow"
  run_cmd "y"

  window_root "$HOME/stow/clash/.config/clash"
  new_window "clash"

  window_root "$HOME/stow/tools/Prometheus"
  new_window "prometheus"

  select_pane 1
  select_window "stow"
fi

# Finalize session creation and switch/attach to it.
finalize_and_go_to_session
