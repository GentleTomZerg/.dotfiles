-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()
local act = wezterm.action

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
config.window_close_confirmation = "NeverPrompt"

-- Color scheme
config.color_scheme = "Catppuccin Macchiato"

-- Disable Ligatures
config.harfbuzz_features = { "calt = 0", "clig = 0", "liga = 0" }

-- Cursor
config.cursor_thickness = 4

-- Keys
config.keys = {
	{ key = "n", mods = "CMD", action = act.SendString("\x1bn") },
	{ key = "h", mods = "CMD", action = act.SendString("\x1bh") },
	{ key = "j", mods = "CMD", action = act.SendString("\x1bj") },
	{ key = "k", mods = "CMD", action = act.SendString("\x1bk") },
	{ key = "l", mods = "CMD", action = act.SendString("\x1bl") },
	{ key = "i", mods = "CMD", action = act.SendString("\x1bi") },
	{ key = "o", mods = "CMD", action = act.SendString("\x1bo") },
	{ key = "f", mods = "CMD", action = act.SendString("\x1bf") },
	{ key = "+", mods = "CMD", action = act.SendString("\x1b+") },
	{ key = "-", mods = "CMD", action = act.SendString("\x1b-") },
	{ key = "f", mods = "CMD", action = act.SendString("\x1bf") },
}

-- Finally, return the configuration to wezterm:
return config
