-- Port of keybindings.conf

local scrPath = os.getenv("HOME") .. "/.local/share/bin"
local mod     = "SUPER"

local term    = "kitty"
local editor  = "code"
local file    = "thunar"
local browser = "zen"

local dsp = hl.dsp
local function bind(keys, action, opts) hl.bind(keys, action, opts) end
local function exec(cmd) return dsp.exec_cmd(cmd) end
local function rofi(cmd) return exec("pkill -x rofi || " .. cmd) end

-- Window/Session actions
bind(mod .. " + SHIFT + P", exec("hyprpicker -a"), { description = "Color Picker" })

-- Close focused window, but only hide Steam (port of dontkillsteam.sh)
local function closeWindow()
    local w = hl.get_active_window()
    if w and w.class == "Steam" then
        hl.exec_cmd("xdotool windowunmap $(xdotool getactivewindow)")
    else
        hl.dispatch(dsp.window.close())
    end
end
bind("ALT + Q",  closeWindow)
bind("ALT + F4", closeWindow)

bind(mod .. " + Delete", dsp.exit())
bind(mod .. " + G", dsp.group.toggle())
bind("ALT + F", dsp.window.fullscreen())
bind(mod .. " + L", exec(os.getenv("HOME") .. "/.local/bin/hyprlock-timed"))

-- Toggle pin; pinning floats the window, unpinning re-tiles it (port of windowpin.sh)
bind(mod .. " + SHIFT + F", function()
    local w = hl.get_active_window()
    if not w then return end
    if not w.pinned then
        if not w.floating then hl.dispatch(dsp.window.float({ action = "set" })) end
        hl.dispatch(dsp.window.pin({ action = "set" }))
    else
        hl.dispatch(dsp.window.pin({ action = "unset" }))
        hl.dispatch(dsp.window.float({ action = "unset" }))
    end
end)

bind(mod .. " + BackSpace", exec(scrPath .. "/logoutlaunch.sh"))
bind("CTRL + ALT + W", exec("killall waybar || (env reload_flag=1 " .. scrPath .. "/wbarconfgen.sh)"))

-- Application shortcuts
bind("ALT + Return", exec(term))
bind("ALT + T", exec(file))
bind(mod .. " + C", exec(editor))
bind(mod .. " + F", exec(browser))
bind("CTRL + SHIFT + Escape", exec(scrPath .. "/sysmonlaunch.sh"))

-- Cycle windows, bring floating ones to top
bind("ALT + Tab", function()
    hl.dispatch(dsp.window.cycle_next())
    hl.dispatch(dsp.window.alter_zorder({ mode = "top" }))
end)

-- Rofi menus
bind(mod .. " + space",       rofi(scrPath .. "/rofilaunch.sh d"))
bind(mod .. " + Tab",         rofi(scrPath .. "/rofilaunch.sh w"))
bind(mod .. " + SHIFT + E",   rofi(scrPath .. "/rofilaunch.sh f"))

-- Audio control
local vol = scrPath .. "/volumecontrol.sh"
bind("F10", exec(vol .. " -o m"), { locked = true })
bind("F11", exec(vol .. " -o d"), { locked = true, repeating = true })
bind("F12", exec(vol .. " -o i"), { locked = true, repeating = true })
bind("XF86AudioMute",        exec(vol .. " -o m"), { locked = true })
bind("XF86AudioMicMute",     exec(vol .. " -i m"), { locked = true })
bind("XF86AudioLowerVolume", exec(vol .. " -o d"), { locked = true, repeating = true })
bind("XF86AudioRaiseVolume", exec(vol .. " -o i"), { locked = true, repeating = true })

-- Media control
bind("XF86AudioPlay",  exec("playerctl play-pause"), { locked = true })
bind("XF86AudioPause", exec("playerctl play-pause"), { locked = true })
bind("XF86AudioNext",  exec("playerctl next"),       { locked = true })
bind("XF86AudioPrev",  exec("playerctl previous"),   { locked = true })

-- Brightness control
bind("XF86MonBrightnessUp",   exec(scrPath .. "/brightnesscontrol.sh i"), { locked = true, repeating = true })
bind("XF86MonBrightnessDown", exec(scrPath .. "/brightnesscontrol.sh d"), { locked = true, repeating = true })

-- Move between grouped windows
bind(mod .. " + CTRL + H", dsp.group.prev())
bind(mod .. " + CTRL + L", dsp.group.next())

-- Screenshot/Screencapture
local shot = scrPath .. "/screenshot.sh"
bind(mod .. " + P",         exec(shot .. " s"))
bind(mod .. " + SHIFT + S", exec(shot .. " sf"))
bind(mod .. " + ALT + P",   exec(shot .. " m"))
bind("Print",               exec(shot .. " p"))

-- Custom scripts
bind(mod .. " + ALT + G", exec(scrPath .. "/gamemode.sh"))
bind("CTRL + ALT + M", exec([[~/.config/hypr/toggle-monitor.sh && hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })']]))
bind(mod .. " + ALT + Right", exec(scrPath .. "/swwwallpaper.sh -n"))
bind(mod .. " + ALT + Left",  exec(scrPath .. "/swwwallpaper.sh -p"))
bind(mod .. " + ALT + Up",    exec(scrPath .. "/wbarconfgen.sh n"))
bind(mod .. " + ALT + Down",  exec(scrPath .. "/wbarconfgen.sh p"))
bind(mod .. " + SHIFT + R", rofi(scrPath .. "/wallbashtoggle.sh -m"))
bind(mod .. " + SHIFT + T", rofi(scrPath .. "/themeselect.sh"))
bind(mod .. " + SHIFT + A", rofi(scrPath .. "/rofiselect.sh"))
bind(mod .. " + SHIFT + X", rofi(scrPath .. "/themestyle.sh"))
bind(mod .. " + SHIFT + W", rofi(scrPath .. "/swwwallselect.sh"))
bind(mod .. " + V",         rofi(scrPath .. "/cliphist.sh c"))
bind(mod .. " + SHIFT + V", rofi(scrPath .. "/cliphist.sh"))
bind(mod .. " + K",         exec(scrPath .. "/keyboardswitch.sh"))
bind(mod .. " + slash",     rofi(scrPath .. "/keybinds_hint.sh c"))

-- Move focus
bind(mod .. " + A", dsp.focus({ direction = "left" }))
bind(mod .. " + D", dsp.focus({ direction = "right" }))
bind(mod .. " + W", dsp.focus({ direction = "up" }))
bind(mod .. " + S", dsp.focus({ direction = "down" }))

-- Workspaces: switch / move (follow) / move silently
for i = 1, 10 do
    local key = tostring(i % 10)
    bind(mod .. " + " .. key,           dsp.focus({ workspace = i }))
    bind(mod .. " + SHIFT + " .. key,   dsp.window.move({ workspace = i, follow = true }))
    bind(mod .. " + ALT + " .. key,     dsp.window.move({ workspace = i, follow = false }))
end

-- Next/previous workspace ID on this monitor, skipping IDs that live on other monitors.
-- Empty IDs are fair game, so ALT + D keeps creating new workspaces here.
local function stepWorkspace(delta)
    return function()
        local mon = hl.get_active_monitor()
        local cur = mon and mon.active_workspace
        if not cur or not cur.id or cur.id < 1 then return end
        local elsewhere = {}
        for _, ws in ipairs(hl.get_workspaces()) do
            if ws.id and ws.monitor and ws.monitor.id ~= mon.id then elsewhere[ws.id] = true end
        end
        local id = cur.id + delta
        while id >= 1 and elsewhere[id] do id = id + delta end
        if id >= 1 then
            hl.dispatch(dsp.focus({ workspace = id, on_current_monitor = true }))
        end
    end
end
bind("ALT + D", stepWorkspace(1))
bind("ALT + A", stepWorkspace(-1))
bind(mod .. " + CTRL + Down", dsp.focus({ workspace = "empty" }))

bind(mod .. " + CTRL + ALT + Right", dsp.window.move({ workspace = "r+1", follow = true }))
bind(mod .. " + CTRL + ALT + Left",  dsp.window.move({ workspace = "r-1", follow = true }))

-- Resize windows
bind(mod .. " + SHIFT + Right", dsp.window.resize({ x = 30,  y = 0,   relative = true }), { repeating = true })
bind(mod .. " + SHIFT + Left",  dsp.window.resize({ x = -30, y = 0,   relative = true }), { repeating = true })
bind(mod .. " + SHIFT + Up",    dsp.window.resize({ x = 0,   y = -30, relative = true }), { repeating = true })
bind(mod .. " + SHIFT + Down",  dsp.window.resize({ x = 0,   y = 30,  relative = true }), { repeating = true })

-- Move active window: floating -> nudge 30px, tiled -> swap in direction
local function moveActive(dir, dx, dy)
    return function()
        local w = hl.get_active_window()
        if w and w.floating then
            hl.dispatch(dsp.window.move({ x = dx, y = dy, relative = true }))
        else
            hl.dispatch(dsp.window.move({ direction = dir }))
        end
    end
end
bind(mod .. " + SHIFT + CTRL + Left",  moveActive("left",  -30, 0))
bind(mod .. " + SHIFT + CTRL + Right", moveActive("right",  30, 0))
bind(mod .. " + SHIFT + CTRL + Up",    moveActive("up",     0, -30))
bind(mod .. " + SHIFT + CTRL + Down",  moveActive("down",   0, 30))

-- Move/Resize with mouse
bind(mod .. " + mouse:272", dsp.window.drag(),   { mouse = true })
bind(mod .. " + mouse:273", dsp.window.resize(), { mouse = true })
bind(mod .. " + Z",         dsp.window.drag(),   { mouse = true })
bind(mod .. " + X",         dsp.window.resize(), { mouse = true })

-- Scratchpad
bind(mod .. " + ALT + S", dsp.window.move({ workspace = "special", follow = false }))

-- Toggle split (dwindle)
bind(mod .. " + J", dsp.layout("togglesplit"))
