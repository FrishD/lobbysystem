Config = {}

Config.DefaultTheme = "dark"  -- "light" or "dark"

Config.LobbyCommand = "lobby"

-- Bucket management for Ramp lobbies
Config.AvailableRampBuckets = { "ramp1", "ramp2", "ramp3", "ramp4", "ramp5" }
Config.UsedRampBuckets = {}

-- OnMenu teleport location (optional)
Config.OnMenu = {
    Teleport = true,
    TeleportCoords = vec4(2178.21, 2913.26, -84.80, 66.19)
}

-- Game mode coordinates
Config.RampCoordinates = { x = 1100.0, y = 220.0, z = -50.0 }

Config.PVPMaps = {
    zakim = {
        TEAM1 = { x = -75.0, y = -820.0, z = 326.0 },
        TEAM2 = { x = -150.0, y = -820.0, z = 326.0 }
    },
    zaira = {
        TEAM1 = { x = 290.0, y = -970.0, z = 29.0 },
        TEAM2 = { x = 260.0, y = -970.0, z = 29.0 }
    }
}

Config.Weapons = {
    "WEAPON_PISTOL",
    "WEAPON_SMG",
    "WEAPON_RIFLE"
}

Config.Locale = {
    players = "Players",
    connect = "Connect",
    light = "Light",
    dark = "Dark",
    close = "Close"
}
