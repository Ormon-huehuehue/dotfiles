-- macOS-style preset (port of animations/animations-macos.conf).
hl.config({ animations = { enabled = true } })

local function bez(name, x0, y0, x1, y1)
    hl.curve(name, { type = "bezier", points = { { x0, y0 }, { x1, y1 } } })
end
bez("spring",     0.16, 1.04, 0.30, 1.00) -- long curvy ease-out, faint overshoot
bez("springSoft", 0.22, 1.00, 0.36, 1.00) -- easeOutQuint, no bounce
bez("macOut",     0.40, 0.00, 0.60, 0.20) -- quick accelerate-out
bez("macEase",    0.16, 1.00, 0.30, 1.00) -- easeOutExpo-ish tail
bez("liner",      1, 1, 1, 1)
bez("popOut",     0.32, 0.00, 0.67, 0.00) -- ease-in: starts gently, leaves fast
bez("fadeQuick",  0.00, 0.00, 0.20, 1.00) -- opacity front-loaded so pops never look washed out

-- Real springs (0.55+): slightly under-damped, ~3% overshoot, settles fast.
hl.curve("popSpring", { type = "spring", mass = 1, stiffness = 320, damping = 30 })

local function anim(leaf, speed, curve, style)
    hl.animation({ leaf = leaf, enabled = true, speed = speed, bezier = curve, style = style })
end
local function springAnim(leaf, speed, spring, style)
    hl.animation({ leaf = leaf, enabled = true, speed = speed, spring = spring, style = style })
end
anim("windowsIn",        3.0, "springSoft", "popin 90%") -- grow in place: no sliding across neighbours
anim("windowsOut",       2.0, "macOut",     "slide")
anim("windowsMove",      2.5, "springSoft", "slide")
anim("fade",             3.5, "macEase")
anim("fadeOut",          1.8, "macOut")
-- Popups (rofi, notifications, menus): grow from 94% on a spring with a quick fade,
-- leave by shrinking to 96% while fading slightly faster than they shrink.
springAnim("layersIn",   2.2, "popSpring",  "popin 94%")
anim("layersOut",        1.3, "popOut",     "popin 96%")
anim("fadeLayersIn",     1.0, "fadeQuick")
anim("fadeLayersOut",    1.0, "popOut")
anim("workspaces",       3.0, "springSoft", "slide")
anim("specialWorkspace", 2.5, "spring",     "slidefadevert 15%")
anim("border",           1.6, "liner")
anim("borderangle",      82,  "liner",      "once")

-- Wayland popups (tray menus, right-click menus): quick fade in, quicker fade out.
anim("fadePopupsIn",  1.4, "fadeQuick")
anim("fadePopupsOut", 1.0, "popOut")
