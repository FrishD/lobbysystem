local isInMenu = false

-- Function to open the lobby menu
function OpenLobbyMenu()
    if isInMenu then return end
    isInMenu = true

    -- Teleport to a neutral area if configured
    if Config.OnMenu.Teleport then
        local playerPed = PlayerPedId()
        CachePos = GetEntityCoords(playerPed)
        DoScreenFadeOut(500)
        Wait(500)
        SetEntityCoords(playerPed, Config.OnMenu.TeleportCoords.x, Config.OnMenu.TeleportCoords.y, Config.OnMenu.TeleportCoords.z)
        SetEntityHeading(playerPed, Config.OnMenu.TeleportCoords.w)
        Wait(1000)
        DoScreenFadeIn(500)
    end

    -- Send data to NUI
    TriggerServerEvent("ns-lobbysystem:refreshdata") -- Request fresh steam data
end

-- Event to receive data from server and show menu
RegisterNetEvent("ns-lobbysystem:getdata", function(steamInfo)
    local theme = GetResourceKvpString('lobbytheme') or Config.DefaultTheme

    SendNUIMessage({
        type = "openmenu",
        data = Config,
        theme = theme,
        locale = Config.Locale,
        steaminfo = steamInfo
    })

    SetNuiFocus(true, true)
end)

-- NUI Callback for connecting to a lobby
RegisterNUICallback("connect", function(data, cb)
    if not data or not data.gameMode then
        print("Invalid data received from NUI")
        cb('error')
        return
    end

    TriggerServerEvent("ns-lobbysystem:connect", data)

    -- After sending data, handle client-side effects
    if Config.OnMenu.Teleport and CachePos then
        DoScreenFadeOut(500)
        Wait(500)
        -- The server will handle teleporting to the game lobby,
        -- so we don't need to teleport back to CachePos here.
        -- We just need to clean up the menu state.
    end

    CloseLobbyMenu()
    cb('ok')
end)


-- Function to close the menu
function CloseLobbyMenu()
    if not isInMenu then return end

    SetNuiFocus(false, false)
    isInMenu = false

    -- If teleported, return to original position
    if Config.OnMenu.Teleport and CachePos then
        DoScreenFadeOut(500)
        Wait(500)
        SetEntityCoords(PlayerPedId(), CachePos.x, CachePos.y, CachePos.z)
        CachePos = nil
        Wait(1000)
        DoScreenFadeIn(500)
    end
end

-- NUI Callback to close the menu
RegisterNUICallback("close", function(data, cb)
    CloseLobbyMenu()
    cb('ok')
end)

-- Command to open the lobby
RegisterCommand(Config.LobbyCommand, function()
    OpenLobbyMenu()
end)
