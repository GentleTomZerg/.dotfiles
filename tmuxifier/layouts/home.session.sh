# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.
session_root "$HOME"

# Create session with specified name if it does not already exist. If no
# argument is given, session name will be based on layout file name.
if initialize_session "home"; then
  window_root "$HOME"
  new_window "package_manager"

  select_window "package_manager"
fi

# Finalize session creation and switch/attach to it.
finalize_and_go_to_session
