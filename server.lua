
local Lobbies = {}
local NextLobbyId = 1

-- Function to get player counts for each bucket
function GetBucketPlayerCount()
    local bucketCounts = {}
    for _, playerId in ipairs(GetPlayers()) do
        local playerBucket = GetPlayerRoutingBucket(playerId)
        if not bucketCounts[playerBucket] then
            bucketCounts[playerBucket] = 0
        end
        bucketCounts[playerBucket] = bucketCounts[playerBucket] + 1
    end
    return bucketCounts
end

-- Function to send updated lobby list to all clients
function UpdateLobbies()
    local lobbyList = {}
    for id, lobby in pairs(Lobbies) do
        table.insert(lobbyList, {
            id = id,
            name = lobby.name,
            players = #lobby.players,
            maxPlayers = lobby.maxPlayers,
            status = #lobby.players >= (lobby.maxPlayers or 999) and "Full" or "Open",
            type = lobby.type
        })
    end
    TriggerClientEvent("ns-lobbysystem:openMenu", -1, lobbyList, Config.Weapons)
end

-- Request lobby list
RegisterNetEvent("ns-lobbysystem:requestLobbies")
AddEventHandler("ns-lobbysystem:requestLobbies", function()
    UpdateLobbies()
end)

-- Create a new lobby
RegisterNetEvent("ns-lobbysystem:createLobby")
AddEventHandler("ns-lobbysystem:createLobby", function(data)
    local src = source
    local lobbyId = NextLobbyId
    local bucket

    if data.type == 'ramp' then
        if #Config.AvailableRampBuckets > 0 then
            bucket = table.remove(Config.AvailableRampBuckets, 1)
            table.insert(Config.UsedRampBuckets, bucket)
        else
            -- Optionally, notify the player that no ramp lobbies are available
            return
        end
    else
        bucket = "lobby_" .. lobbyId
    end

    Lobbies[lobbyId] = {
        name = data.name,
        type = data.type,
        players = {src},
        maxPlayers = nil, -- Or get from UI
        bucket = bucket
    }
    SetPlayerRoutingBucket(src, bucket)
    NextLobbyId = NextLobbyId + 1
    UpdateLobbies()

    local lobbyData = Lobbies[lobbyId]
    lobbyData.players = GetPlayerNamesFromIds(lobbyData.players)
    TriggerClientEvent("ns-lobbysystem:showDashboard", src, lobbyData)
end)

-- Join an existing lobby
RegisterNetEvent("ns-lobbysystem:joinLobby")
AddEventHandler("ns-lobbysystem:joinLobby", function(lobbyId)
    local src = source
    if Lobbies[lobbyId] then
        table.insert(Lobbies[lobbyId].players, src)
        SetPlayerRoutingBucket(src, Lobbies[lobbyId].bucket)
        UpdateLobbies()

        local lobbyData = Lobbies[lobbyId]
        lobbyData.players = GetPlayerNamesFromIds(lobbyData.players)
        TriggerClientEvent("ns-lobbysystem:showDashboard", src, lobbyData)
    end
end)

-- Start the game
RegisterNetEvent("ns-lobbysystem:startGame")
AddEventHandler("ns-lobbysystem:startGame", function(data)
    local src = source
    local lobby = nil
    -- Find the lobby the player is in
    for id, l in pairs(Lobbies) do
        for _, p in ipairs(l.players) do
            if p == src then
                lobby = l
                break
            end
        end
        if lobby then break end
    end

    if not lobby then return end

    if lobby.type == 'ramp' then
        for _, playerSrc in ipairs(lobby.players) do
            TriggerClientEvent("ns-lobbysystem:teleport", playerSrc, Config.RampCoordinates)
        end
    elseif lobby.type == 'pvp' then
        local mapCoords = Config.PVPMaps[data.map]
        if not mapCoords then return end

        -- Teleport the initiating player to their chosen team and give weapon
        local initiatorCoords = mapCoords[data.team]
        if initiatorCoords then
            TriggerClientEvent("ns-lobbysystem:teleport", src, initiatorCoords)
            TriggerClientEvent("ns-lobbysystem:giveWeapon", src, data.weapon)
        end

        -- Assign remaining players to the opposing team and give weapon
        local opposingTeam = (data.team == "TEAM1") and "TEAM2" or "TEAM1"
        local opposingCoords = mapCoords[opposingTeam]
        if opposingCoords then
            for _, playerSrc in ipairs(lobby.players) do
                if playerSrc ~= src then
                    TriggerClientEvent("ns-lobbysystem:teleport", playerSrc, opposingCoords)
                    TriggerClientEvent("ns-lobbysystem:giveWeapon", playerSrc, data.weapon)
                end
            end
        end
    end
end)


-- Player dropping logic
AddEventHandler('playerDropped', function(reason)
    local src = source
    for id, lobby in pairs(Lobbies) do
        for i, player in ipairs(lobby.players) do
            if player == src then
                table.remove(lobby.players, i)
                if #lobby.players == 0 then
                    if lobby.type == 'ramp' then
                        for i, bucket in ipairs(Config.UsedRampBuckets) do
                            if bucket == lobby.bucket then
                                table.remove(Config.UsedRampBuckets, i)
                                table.insert(Config.AvailableRampBuckets, lobby.bucket)
                                break
                            end
                        end
                    end
                    Lobbies[id] = nil -- Delete empty lobby
                end
                UpdateLobbies()
                return
            end
        end
    end
end)

function GetPlayerNamesFromIds(playerIds)
    local names = {}
    for _, id in ipairs(playerIds) do
        table.insert(names, {name = GetPlayerName(id) or "Unknown"})
    end
    return names
end
