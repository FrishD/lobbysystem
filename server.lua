
-- Helper function to extract Steam ID
local function ExtractSteamID(src)
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if string.find(id, "steam") then
            return id:gsub("steam:", "")
        end
    end
    return nil
end

-- Fetch Steam data for the UI
RegisterNetEvent("ns-lobbysystem:refreshdata", function()
    local src = source
    local steamIDHex = ExtractSteamID(src)
    if not steamIDHex then
        print("Could not find Steam ID for player " .. src)
        return
    end

    local steamID64 = tonumber(steamIDHex, 16)
    local steamAPIKey = Config.steamAPIKey

    if not steamAPIKey or steamAPIKey == "" then
        print("Steam API Key is not set in config.lua")
        -- Trigger client event even without steam info, so UI can open
        TriggerClientEvent("ns-lobbysystem:getdata", src, nil)
        return
    end

    local steamAPIURL = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=" .. steamAPIKey .. "&steamids=" .. steamID64

    PerformHttpRequest(steamAPIURL, function(err, text, headers)
        if err ~= 200 then
            print("Failed to fetch Steam data, error " .. err)
            TriggerClientEvent("ns-lobbysystem:getdata", src, nil)
            return
        end

        local data = json.decode(text)
        if data and data.response and data.response.players and #data.response.players > 0 then
            local player = data.response.players[1]
            local steamInfo = {
                isim = player.personaname,
                steamfoto = player.avatarfull
            }
            TriggerClientEvent("ns-lobbysystem:getdata", src, steamInfo)
        else
            TriggerClientEvent("ns-lobbysystem:getdata", src, nil)
        end
    end)
end)

-- Main event to handle a player connecting to a lobby
RegisterNetEvent('ns-lobbysystem:connect', function(data)
    local src = source
    local gameMode = data.gameMode
    local lobbyId = data.lobbyId
    local team = data.team
    local weapon = data.weapon

    if not Config.GameModes[gameMode] then
        print("Invalid game mode selected by player " .. src)
        return
    end

    local settings = Config.GameModes[gameMode].Settings
    local targetBucket
    local teleportCoords

    -- Determine the routing bucket
    if gameMode == "Ramps" then
        -- For Ramps, find the first available bucket from the pool
        local bucketCounts = GetBucketPlayerCount()
        local foundBucket = false
        for _, bucket in ipairs(settings.BucketPool) do
            if not bucketCounts[tostring(bucket)] or bucketCounts[tostring(bucket)] == 0 then
                targetBucket = bucket
                -- Find the corresponding ramp coordinates
                local lobbyIndex = lobbyId and tonumber(lobbyId)
                if lobbyIndex and settings.Lobbies[lobbyIndex] then
                    teleportCoords = settings.Lobbies[lobbyIndex].coords
                else
                    -- Default to first ramp if lobbyId is not provided or invalid
                    teleportCoords = settings.Lobbies[1].coords
                end
                foundBucket = true
                break
            end
        end
        if not foundBucket then
            print("No available ramp lobbies for player " .. src)
            -- Optionally, send a notification to the player
            return
        end
    else -- For Zaira and Zakim
        if not lobbyId then
            print("Lobby ID is required for Zaira/Zakim for player " .. src)
            return
        end
        targetBucket = settings.BucketBase + lobbyId

        if settings.TeamSelection and team then
            teleportCoords = settings.TeleportCoords["Team" .. team]
        else
            -- Fallback to a default coord if something goes wrong
            teleportCoords = settings.TeleportCoords.Team1
        end
    end

    -- Set the player's routing bucket
    SetPlayerRoutingBucket(src, targetBucket)
    print("Player " .. src .. " moved to bucket " .. targetBucket)

    -- Teleport the player
    if teleportCoords then
        TriggerClientEvent('ns-lobbysystem:teleport', src, teleportCoords)
    end

    -- Give the selected weapon
    if settings.WeaponSelection and weapon then
        local playerPed = GetPlayerPed(src)
        GiveWeaponToPed(playerPed, GetHashKey(weapon), 250, false, true)
    end
end)

-- Client event for teleportation
RegisterNetEvent('ns-lobbysystem:teleport', function(coords)
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, true)
end)


-- Helper function to get player counts in each bucket
function GetBucketPlayerCount()
    local bucketCounts = {}
    for _, playerId in ipairs(GetPlayers()) do
        local playerBucket = GetPlayerRoutingBucket(playerId)
        local bucketStr = tostring(playerBucket)
        if not bucketCounts[bucketStr] then
            bucketCounts[bucketStr] = 0
        end
        bucketCounts[bucketStr] = bucketCounts[bucketStr] + 1
    end
    return bucketCounts
end
