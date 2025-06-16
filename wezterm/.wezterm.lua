-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.font_size = 14

config.enable_tab_bar = false

config.window_decorations = "RESIZE"

config.window_background_opacity = 0.7
config.macos_window_background_blur = 20

config.color_scheme = "One Dark (Gogh)"

-- Finally, return the configuration to wezterm:
return config
