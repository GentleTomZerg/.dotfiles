-- Migrated from tmux (prefix ctrl+space).
rex.bind("ctrl+space>enter", "pane.split.auto") -- best-fit split
rex.bind("ctrl+space>r", "client.config.reload")

-- tmux-style pane focus: arrows and vim keys.
-- wrap = false keeps tmux behaviour: focus stops at the edge.
rex.bind("ctrl+space>left", "pane.focus", { direction = "left", wrap = false })
rex.bind("ctrl+space>right", "pane.focus", { direction = "right", wrap = false })
rex.bind("ctrl+space>up", "pane.focus", { direction = "up", wrap = false })
rex.bind("ctrl+space>down", "pane.focus", { direction = "down", wrap = false })
rex.bind("ctrl+space>h", "pane.focus", { direction = "left", wrap = false })
rex.bind("ctrl+space>j", "pane.focus", { direction = "down", wrap = false })
rex.bind("ctrl+space>k", "pane.focus", { direction = "up", wrap = false })
rex.bind("ctrl+space>l", "pane.focus", { direction = "right", wrap = false })

-- tmux-style pane and tab navigation.
rex.bind("ctrl+space>o", "pane.focus_next")
rex.bind("ctrl+space>;", "pane.focus_recent")
rex.bind("ctrl+space>z", "pane.zoom")
rex.bind("ctrl+space>x", "pane.close")
rex.bind("ctrl+space>c", "client.tab.new")
rex.bind("ctrl+space>n", "client.tab.next")
rex.bind("ctrl+space>p", "client.tab.previous")
rex.bind("ctrl+space>shift+7", "client.tab.close") -- & kills the tab
rex.bind("ctrl+space>shift+,", "client.tab.move.backward") -- < swaps tab left
rex.bind("ctrl+space>shift+.", "client.tab.move.forward") -- > swaps tab right
rex.bind("ctrl+space>s", "session.switch")
rex.bind("ctrl+space>shift+;", "client.palette.toggle") -- tmux command prompt (:)
rex.bind("ctrl+space>w", "pane.go_to")

-- tmux-style copy mode: prefix + [ enters copy mode.
rex.bind("ctrl+space>[", "pane.copy_mode.enter")

-- Let the prefix reach programs that use ctrl+space themselves.
rex.bind("ctrl+space>ctrl+space", "pane.send_key", { key = "ctrl+space" })
