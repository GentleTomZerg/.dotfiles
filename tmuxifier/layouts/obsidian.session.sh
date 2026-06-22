# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.
session_root "$HOME/Projects/Obsidian-Vault"

# Create session with specified name if it does not already exist. If no
# argument is given, session name will be based on layout file name.
if initialize_session "obsidian"; then
  window_root "$HOME/Projects/Obsidian-Vault"
  new_window "note"

  select_window "note"
fi

# Finalize session creation and switch/attach to it.
finalize_and_go_to_session
