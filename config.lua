Config = {}

Config.steamAPIKey = "" -- Make sure to set your Steam API Key here.

Config.LobbyCommand = "lobby"

Config.DefaultTheme = "dark" -- "light" or "dark"

Config.GameModes = {
    Zaira = {
        Label = "Zaira",
        Image = "https://nexusdev.online/assets/img/nexusreklam.png", -- Placeholder Image
        Description = "Competitive PVP mode.",
        Settings = {
            TeamSelection = true,
            WeaponSelection = true,
            Weapons = {
                { name = "Pistol", hash = "WEAPON_PISTOL" },
                { name = "Combat Pistol", hash = "WEAPON_COMBATPISTOL" },
                { name = "SMG", hash = "WEAPON_SMG" },
            },
            BucketBase = 1000, -- Lobbies will be BucketBase + LobbyID
            TeleportCoords = {
                Team1 = vector3(-234.34, -1620.17, 34.82),
                Team2 = vector3(-204.38, -1604.29, 34.82)
            }
        }
    },
    Zakim = {
        Label = "Zakim",
        Image = "https://nexusdev.online/assets/img/nexusreklam.png", -- Placeholder Image
        Description = "Team-based objective mode.",
        Settings = {
            TeamSelection = true,
            WeaponSelection = true,
            Weapons = {
                { name = "Carbine Rifle", hash = "WEAPON_CARBINERIFLE" },
                { name = "Assault Rifle", hash = "WEAPON_ASSAULTRIFLE" },
                { name = "Sniper Rifle", hash = "WEAPON_SNIPERRIFLE" },
            },
            BucketBase = 2000, -- Lobbies will be BucketBase + LobbyID
            TeleportCoords = {
                Team1 = vector3(484.51, -1533.15, 29.28),
                Team2 = vector3(451.8, -1523.95, 29.28)
            }
        }
    },
    Ramps = {
        Label = "Ramps",
        Image = "https://nexusdev.online/assets/img/nexusreklam.png", -- Placeholder Image
        Description = "Freestyle ramp jumping.",
        Settings = {
            TeamSelection = false,
            WeaponSelection = false,
            -- For Ramps, the server will automatically assign a bucket from this list.
            -- The lobby ID from the UI is just for display/future use and doesn't select the bucket.
            Lobbies = {
                { icon = '🛹', label = 'Skate Ramp', coords = vector3(-958.58, -780.19, 17.83) },
                { icon = '🏀', label = 'Basketball Ramp', coords = vector3(-921.04, -744.49, 19.89) },
                { icon = '🆕', label = 'New Ramps 1', coords = vector3(-2563.11, -1451.54, 36.96) },
            },
            -- Each lobby above will be assigned a unique bucket by the server logic.
            -- We can define a range or let the server manage it dynamically.
            BucketPool = { 3001, 3002, 3003, 3004, 3005 } -- Example pool of available buckets
        }
    }
}

Config.OnMenu = {
    Teleport = true,
    TeleportCoords = vec4(2178.21, 2913.26, -84.80, 66.19)
}

Config.Locale = {
    players = "Players",
    connect = "Connect",
    light = "Light",
    dark = "Dark",
    close = "Close",
    lobby_id = "Lobby ID",
    team_1 = "Team 1",
    team_2 = "Team 2",
    select_weapon = "Select Weapon"
}
