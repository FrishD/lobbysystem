local CachePos = nil
local CacheBucket = nil

-- Event to receive lobby data from server and open the menu
RegisterNetEvent('ns-lobbysystem:openMenu', function(lobbies, weapons)
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "openmenu",
        lobbies = lobbies,
        weapons = weapons
    })
end)

-- NUI Callback for creating a lobby
RegisterNUICallback("createLobby", function(data, cb)
    TriggerServerEvent("ns-lobbysystem:createLobby", data)
    cb('ok')
end)

-- NUI Callback for joining a lobby
RegisterNUICallback("joinLobby", function(data, cb)
    TriggerServerEvent("ns-lobbysystem:joinLobby", data.id)
    cb('ok')
end)

-- NUI Callback for starting the game
RegisterNUICallback("startGame", function(data, cb)
    TriggerServerEvent("ns-lobbysystem:startGame", data)
    cb('ok')
end)


-- Event to show the lobby dashboard
RegisterNetEvent('ns-lobbysystem:showDashboard', function(lobbyData)
    SendNUIMessage({
        type = "showDashboard",
        lobby = lobbyData
    })
end)


-- NUI Callback for closing the menu
RegisterNUICallback("close", function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Command to open the lobby menu
RegisterCommand(Config.LobbyCommand, function()
    TriggerServerEvent("ns-lobbysystem:requestLobbies")
end)

-- Teleport event
RegisterNetEvent('ns-lobbysystem:teleport', function(coords)
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, coords.x, coords.y, coords.z)
    SetEntityHeading(playerPed, coords.w or 0.0)
end)

-- Give weapon event
RegisterNetEvent('ns-lobbysystem:giveWeapon', function(weaponName)
    local playerPed = PlayerPedId()
    local weaponHash = GetHashKey(weaponName)
    GiveWeaponToPed(playerPed, weaponHash, 250, false, true)
end)
