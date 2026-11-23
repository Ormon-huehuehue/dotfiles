-- Port of windowrules.conf

local function opacity(match, value)
    hl.window_rule({ match = match, opacity = value })
end

for _, class in ipairs({ "firefox", "Google-chrome", "Brave-browser", "com.github.rafostar.Clapper" }) do
    opacity({ class = "^(" .. class .. ")$" }, "0.90 0.90")
end

for _, class in ipairs({
    "code-oss", "[Cc]ode", "code-url-handler", "code-insiders-url-handler", "kitty",
    "org.kde.dolphin", "org.kde.ark", "nwg-look", "qt5ct", "qt6ct", "kvantummanager",
    "com.github.tchx84.Flatseal", "hu.kramo.Cartridges", "com.obsproject.Studio", "gnome-boxes",
    "vesktop", "discord", "WebCord", "ArmCord", "app.drey.Warp", "net.davidotek.pupgui2", "yad",
    "Signal", "io.github.alainm23.planify", "io.gitlab.theevilskeleton.Upscaler",
    "com.github.unrud.VideoDownloader", "io.gitlab.adhami3310.Impression",
    "io.missioncenter.MissionCenter", "io.github.flattool.Warehouse",
}) do
    opacity({ class = "^(" .. class .. ")$" }, "0.80 0.80")
end

for _, class in ipairs({
    "org.pulseaudio.pavucontrol", "blueman-manager", "nm-applet", "nm-connection-editor",
    "org.kde.polkit-kde-authentication-agent-1", "polkit-gnome-authentication-agent-1",
    "org.freedesktop.impl.portal.desktop.gtk", "org.freedesktop.impl.portal.desktop.hyprland",
}) do
    opacity({ class = "^(" .. class .. ")$" }, "0.80 0.70")
end

for _, class in ipairs({ "[Ss]team", "steamwebhelper", "[Ss]potify" }) do
    opacity({ class = "^(" .. class .. ")$" }, "0.70 0.70")
end
opacity({ initial_title = "^(Spotify Free)$" }, "0.70 0.70")
opacity({ initial_title = "^(Spotify Premium)$" }, "0.70 0.70")

-- Floating windows
local function float(match) hl.window_rule({ match = match, float = true }) end

float({ class = "^(org.kde.dolphin)$", title = "^(Progress Dialog — Dolphin)$" })
float({ class = "^(org.kde.dolphin)$", title = "^(Copying — Dolphin)$" })
float({ title = "^(About Mozilla Firefox)$" })
float({ class = "^(firefox)$", title = "^(Picture-in-Picture)$" })
float({ class = "^(firefox)$", title = "^(Library)$" })
for _, t in ipairs({ "top", "btop", "htop" }) do
    float({ class = "^(kitty)$", title = "^(" .. t .. ")$" })
end
for _, class in ipairs({
    "vlc", "kvantummanager", "qt5ct", "qt6ct", "nwg-look", "org.kde.ark",
    "org.pulseaudio.pavucontrol", "blueman-manager", "nm-applet", "nm-connection-editor",
    "org.kde.polkit-kde-authentication-agent-1", "Signal", "com.github.rafostar.Clapper",
    "app.drey.Warp", "net.davidotek.pupgui2", "yad", "eog", "io.github.alainm23.planify",
    "io.gitlab.theevilskeleton.Upscaler", "com.github.unrud.VideoDownloader",
    "io.gitlab.adhami3310.Impression", "io.missioncenter.MissionCenter", "xdg-desktop-portal-gtk",
}) do
    float({ class = "^(" .. class .. ")$" })
end
-- common modals
for _, t in ipairs({ "Open", "Choose Files", "Save As", "Confirm to replace files", "File Operation Progress" }) do
    float({ title = "^(" .. t .. ")$" })
end

-- Electron apps with their own translucent titlebar double-blur; opt them out.
hl.window_rule({ match = { class = "^(com.anthropic.Claude)$" }, no_blur = true })

-- Layer rules
hl.layer_rule({
    name  = "blur-popups",
    match = { namespace = "^(rofi|notifications|swaync-notification-window|swaync-control-center|logout_dialog)$" },
    blur  = true,
    ignore_alpha = 0,
})

-- macOS-style dock: frosted glass behind its translucent background, no Hyprland layer animation
-- (the dock animates its own slide).
hl.layer_rule({
    name  = "dock-glass",
    match = { namespace = "^(hyprland-dock)$" },
    blur  = true,
    ignore_alpha = 0.02,
    no_anim = true,
})

-- Floating windows (dialogs, pickers, pavucontrol...) pop in instead of sliding.
hl.window_rule({ name = "float-popin", match = { float = true }, animation = "popin 94%" })

-- Waybar tray menus (Wi-Fi/Bluetooth dropdowns): blur behind their translucent background.
hl.layer_rule({ name = "waybar-popups", match = { namespace = "^(waybar)$" }, blur_popups = true, ignore_alpha = 0.1 })

-- Wi-Fi/Bluetooth dropdowns (Quickshell): frosted glass, animates itself.
hl.layer_rule({ name = "netmenu-glass", match = { namespace = "^(netmenu)$" }, blur = true, ignore_alpha = 0.01, no_anim = true })


-- Apps (kitty included) ask to open maximized; ignore that so new windows tile normally.
hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })
