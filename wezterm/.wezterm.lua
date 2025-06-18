-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Fonts
config.font_size = 14
config.font = wezterm.font_with_fallback({
  "FiraCode Nerd Font",
  "LXGW WenKai",
})

-- Window
config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.7
config.macos_window_background_blur = 20

-- Color scheme
config.color_scheme = "Catppuccin Macchiato"

-- Disable Ligatures
config.harfbuzz_features = { "calt = 0", "clig = 0", "liga = 0" }

-- Cursor
config.cursor_thickness = 4

-- Finally, return the configuration to wezterm:
return config
