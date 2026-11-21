-- Migrated from tmux (prefix ctrl+space).
rex.bind("ctrl+space>enter", "pane.split.auto")  -- best-fit split
rex.bind("ctrl+space>r", "client.config.reload")

-- tmux-style pane focus: arrows and vim keys.
rex.bind("ctrl+space>left", "pane.focus", { direction = "left" })
rex.bind("ctrl+space>right", "pane.focus", { direction = "right" })
rex.bind("ctrl+space>up", "pane.focus", { direction = "up" })
rex.bind("ctrl+space>down", "pane.focus", { direction = "down" })
rex.bind("ctrl+space>h", "pane.focus", { direction = "left" })
rex.bind("ctrl+space>j", "pane.focus", { direction = "down" })
rex.bind("ctrl+space>k", "pane.focus", { direction = "up" })
rex.bind("ctrl+space>l", "pane.focus", { direction = "right" })

-- tmux-style pane and tab navigation.
rex.bind("ctrl+space>o", "pane.focus_next")
rex.bind("ctrl+space>;", "pane.focus_recent")
rex.bind("ctrl+space>z", "pane.zoom")
rex.bind("ctrl+space>x", "pane.close")
rex.bind("ctrl+space>c", "client.tab.new")
rex.bind("ctrl+space>n", "client.tab.next")
rex.bind("ctrl+space>p", "client.tab.previous")
rex.bind("ctrl+space>shift+7", "client.tab.close")
rex.bind("ctrl+space>s", "session.switch")
rex.bind("ctrl+space>shift+;", "client.palette.toggle")  -- tmux command prompt (:)
rex.bind("ctrl+space>w", "pane.go_to")

-- Let the prefix reach programs that use ctrl+space themselves.
rex.bind("ctrl+space>ctrl+space", "pane.send_key", { key = "ctrl+space" })
