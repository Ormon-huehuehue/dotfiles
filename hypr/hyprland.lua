-- Hyprland 0.57+ Lua config, converted from hyprland.conf (hyprlang is no longer read).
-- Old .conf files are kept next to this for reference only.

local home    = os.getenv("HOME")
local scrPath = home .. "/.local/share/bin"

---------------
---- ENV ----
---------------
hl.env("PATH", (os.getenv("PATH") or "") .. ":" .. scrPath)
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("GDK_SCALE", "1")
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "12")
hl.env("MOZ_DRM_DEVICE", "/dev/dri/renderD129") -- AMD iGPU (card1 = NVIDIA caused Zen lag)
-- nvidia.conf: AMD iGPU drives the panel; opt into dGPU per-app with PRIME offload.
hl.env("__GL_VRR_ALLOWED", "1")

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("killall xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-desktop-portal-kde")
    hl.exec_cmd("/usr/lib/xdg-desktop-portal-kde &")
    hl.exec_cmd("/usr/lib/xdg-desktop-portal &")
    hl.exec_cmd(scrPath .. "/polkitkdeauth.sh")
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("waybar")
    hl.exec_cmd("systemctl --user start hyprland-dock.service") -- macOS-style dock (systemd restarts it if it exits)
    hl.exec_cmd("qs -p " .. home .. "/.config/quickshell/netmenu -d") -- Wi-Fi/Bluetooth dropdowns for Waybar
    hl.exec_cmd("systemctl --user start blueman-applet.service")
    hl.exec_cmd("udiskie --no-automount --smart-tray")
    hl.exec_cmd("systemctl --user start hypridle.service")
    -- nm-applet tray icon retired: Wi-Fi lives in the Waybar network icon + netmenu
    hl.exec_cmd("dunst")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd(scrPath .. "/batterynotify.sh")
end)

-- Ran on every reload in the old config (themes/common.conf, theme.conf, colors.conf)
hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 20")
hl.exec_cmd([[gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice']])
hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 20")
hl.exec_cmd([[gsettings set org.gnome.desktop.interface font-name 'Cantarell 10']])
hl.exec_cmd([[gsettings set org.gnome.desktop.interface document-font-name 'Cantarell 10']])
hl.exec_cmd([[gsettings set org.gnome.desktop.interface monospace-font-name 'CaskaydiaCove Nerd Font Mono 9']])
hl.exec_cmd([[gsettings set org.gnome.desktop.interface font-antialiasing 'rgba']])
hl.exec_cmd([[gsettings set org.gnome.desktop.interface font-hinting 'full']])
hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme Tela-circle-green")
hl.exec_cmd([[gsettings set org.gnome.desktop.interface gtk-theme 'Wallbash-Gtk']])
hl.exec_cmd([[gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark']])

-----------------------
---- LOOK AND FEEL ----
-----------------------
-- Colors are the wallbash values from themes/colors.conf (last override won).
hl.config({
    general = {
        gaps_in          = 3,
        gaps_out         = { top = 3, right = 8, bottom = 8, left = 8 }, -- top gap matches waybar inner padding
        border_size      = 2,
        layout           = "dwindle",
        resize_on_border = true,
        col = {
            active_border   = { colors = { "rgba(A4B7B5ff)", "rgba(29524Dff)" }, angle = 45 },
            inactive_border = { colors = { "rgba(101419ff)", "rgba(1B2025ff)" }, angle = 45 },
        },
    },

    group = {
        col = {
            border_active          = { colors = { "rgba(A4B7B5ff)", "rgba(29524Dff)" }, angle = 45 },
            border_inactive        = { colors = { "rgba(101419cc)", "rgba(1B2025cc)" }, angle = 45 },
            border_locked_active   = { colors = { "rgba(FFFFFFff)", "rgba(0D0D0Dff)" }, angle = 45 },
            border_locked_inactive = { colors = { "rgba(FFFFFFcc)", "rgba(FFFFFFcc)" }, angle = 45 },
        },
    },

    decoration = {
        rounding    = 10,
        dim_special = 0.3,
        shadow = { enabled = false },
        blur = {
            enabled           = true,
            size              = 5,
            passes            = 4,
            new_optimizations = true,
            ignore_opacity    = true,
            xray              = false,
            special           = true,
            vibrancy          = 0.35, -- macOS-like: keep colours behind glass saturated
            vibrancy_darkness = 0.2,
            brightness        = 1.0,
        },
    },

    input = {
        kb_layout          = "us",
        follow_mouse       = 1,
        sensitivity        = -0.9,
        force_no_accel     = false,
        numlock_by_default = true,
        touchpad = { natural_scroll = true },
    },

    dwindle = { preserve_split = true },
    master  = { new_status = "master" },

    misc = {
        vrr                      = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
        allow_session_lock_restore = true, -- ponytail: lets a new hyprlock take over if one crashes (else black screen)
    },

    xwayland = { force_zero_scaling = false },
    render   = { cm_auto_hdr = 0 },
})

hl.device({ name = "asue140d:00-04f3:31bc-touchpad", sensitivity = 0 })
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

require("monitors")
require("animations")
require("keybinds")
require("rules")
