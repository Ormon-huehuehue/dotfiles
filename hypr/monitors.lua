-- External monitor (right of laptop). toggle-monitor.sh flips which HDMI line is commented.
hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@100", position = "auto-right", scale = 1, bitdepth = 8 }) -- external
-- hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@75", position = "auto-right", scale = 1 }) -- home

-- Laptop screen
local laptop = { output = "eDP-1", mode = "2880x1800@90", position = "0x0", scale = 1.875 }
hl.monitor(laptop)

-- Clamshell: lid closed with an external screen -> disable laptop panel; lid open -> restore.
-- ponytail: resume fires a spurious "Lid closed" (logind logs closed+opened same second);
-- trust ACPI state, not the event, or eDP-1 stays disabled after wake.
local function lid_closed()
    local f = io.open("/proc/acpi/button/lid/LID/state")
    if not f then return true end
    local s = f:read("*a"); f:close()
    return s:find("closed") ~= nil
end

hl.bind("switch:on:Lid Switch", function()
    if #hl.get_monitors() > 1 and lid_closed() then
        hl.monitor({ output = "eDP-1", disabled = true })
    end
end, { locked = true })
hl.bind("switch:off:Lid Switch", function() hl.monitor(laptop) end, { locked = true })

-- Rescue key, works on the lock screen: force laptop panel back on.
hl.bind("CTRL + ALT + E", function()
    hl.monitor(laptop)
    hl.dispatch(hl.dsp.dpms({ action = "enable" }))
end, { locked = true })

-- Rescue key if hyprlock crashed (black/blank lock): start a fresh one.
hl.bind("CTRL + ALT + L", function() hl.exec_cmd("pidof hyprlock || hyprlock") end, { locked = true })
