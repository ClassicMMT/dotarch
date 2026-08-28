-- ### CUSTOM

-- Unbind defaults that conflict with HJKL window navigation
hl.unbind("SUPER + J") -- was: Toggle window split (rebound to Super+;)
hl.unbind("SUPER + K") -- was: Show key bindings
hl.unbind("SUPER + L") -- was: Toggle workspace layout (dwindle<->scrolling) — keep vim focus-right only

-- Rebind toggle window split
o.bind("SUPER + semicolon", "Toggle window split", hl.dsp.layout("togglesplit"))

-- Unbind monitor scaling cycle
hl.unbind("SUPER + SLASH")
hl.unbind("SUPER + ALT + SLASH")

hl.unbind("SUPER + SHIFT + E")

-- Unbind default arrow key window management (now handled by HJKL)
hl.unbind("SUPER + LEFT")
hl.unbind("SUPER + RIGHT")
hl.unbind("SUPER + UP")
hl.unbind("SUPER + DOWN")
hl.unbind("SUPER + SHIFT + LEFT")
hl.unbind("SUPER + SHIFT + RIGHT")
hl.unbind("SUPER + SHIFT + UP")
hl.unbind("SUPER + SHIFT + DOWN")

-- Replace screen recording with super+m
hl.unbind("ALT + PRINT")
o.bind("SUPER + M", "Screenrecording", "omarchy-capture-screenrecording --stop-recording || omarchy-menu toggle trigger.capture.screenrecord")


hl.unbind("SUPER + F")
hl.unbind("SUPER + ALT + F")
o.bind("SUPER + F", "Full width", hl.dsp.window.fullscreen({ mode = "maximized" }))
o.bind("SUPER + ALT + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))


-- Window focus with SUPER + HJKL (vim-style)
o.bind("SUPER + H", "Move window focus left", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + L", "Move window focus right", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + K", "Move window focus up", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + J", "Move window focus down", hl.dsp.focus({ direction = "d" }))

-- Swap windows with SUPER + SHIFT + HJKL
o.bind("SUPER + SHIFT + H", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + L", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))
o.bind("SUPER + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))


-- equalise column widths on the focused monitor
o.bind("SUPER + E", "Equalize columns", "~/.config/hypr/scripts/gridify-columns")


-- hyprwhspr - Toggle mode
-- Press once to start, press again to stop
o.bind("SUPER + D", "Speech-to-text", "/usr/lib/hyprwhspr/config/hyprland/hyprwhspr-tray.sh record")


-- Move ALL windows on the current workspace to another workspace, then follow.
-- SUPER+CTRL+SHIFT+[1-9,0] — mirrors omarchy's SUPER+SHIFT (single-window) map;
o.bind("SUPER + CTRL + SHIFT + code:10", "Move all windows to workspace 1", "~/.config/hypr/scripts/move-all-to-workspace 1")
o.bind("SUPER + CTRL + SHIFT + code:11", "Move all windows to workspace 2", "~/.config/hypr/scripts/move-all-to-workspace 2")
o.bind("SUPER + CTRL + SHIFT + code:12", "Move all windows to workspace 3", "~/.config/hypr/scripts/move-all-to-workspace 3")
o.bind("SUPER + CTRL + SHIFT + code:13", "Move all windows to workspace 4", "~/.config/hypr/scripts/move-all-to-workspace 4")
o.bind("SUPER + CTRL + SHIFT + code:14", "Move all windows to workspace 5", "~/.config/hypr/scripts/move-all-to-workspace 5")
o.bind("SUPER + CTRL + SHIFT + code:15", "Move all windows to workspace 6", "~/.config/hypr/scripts/move-all-to-workspace 6")
o.bind("SUPER + CTRL + SHIFT + code:16", "Move all windows to workspace 7", "~/.config/hypr/scripts/move-all-to-workspace 7")
o.bind("SUPER + CTRL + SHIFT + code:17", "Move all windows to workspace 8", "~/.config/hypr/scripts/move-all-to-workspace 8")
o.bind("SUPER + CTRL + SHIFT + code:18", "Move all windows to workspace 9", "~/.config/hypr/scripts/move-all-to-workspace 9")
o.bind("SUPER + CTRL + SHIFT + code:19", "Move all windows to workspace 10", "~/.config/hypr/scripts/move-all-to-workspace 10")
