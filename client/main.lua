local interactionKeyPressed = false
local interactionKeyOpened = false
---------------------------------------
local headerShown = false
local sendData = nil

-- Functions

local function openMenu(data)
    if not data or not next(data) then return end
    SetNuiFocus(true, true)
    headerShown = false
    sendData = data
    SendNUIMessage({
        action = 'OPEN_MENU',
        data = table.clone(data)
    })
end

local function closeMenu()
    sendData = nil
    headerShown = false
    SetNuiFocus(false)
    SendNUIMessage({
        action = 'CLOSE_MENU'
    })
end

local function showHeader(data, onScreen, coordX, coordY)
    if not data or not next(data) then return end
    headerShown = true
    sendData = data
    SendNUIMessage({
        action = 'SHOW_HEADER',
        data = table.clone(data),
		coordX = coordX+0.1,
		coordY = coordY,
    })
end

-- Events

RegisterNetEvent('new3dinteract:client:openMenu', function(data)
    openMenu(data)
end)

RegisterNetEvent('new3dinteract:client:closeMenu', function()
    closeMenu()
end)

-- NUI Callbacks

RegisterNUICallback('clickedButton', function(option)
    if headerShown then headerShown = false end
    PlaySoundFrontend(-1, 'Highlight_Cancel', 'DLC_HEIST_PLANNING_BOARD_SOUNDS', 1)
    SetNuiFocus(false)
    if sendData then
        local data = sendData[tonumber(option)]
        sendData = nil
        if data then
            if data.params.event then
                if data.params.isServer then
                    TriggerServerEvent(data.params.event, data.params.args)
                elseif data.params.isCommand then
                    ExecuteCommand(data.params.event)
                elseif data.params.isQBCommand then
                    TriggerServerEvent('QBCore:CallCommand', data.params.event, data.params.args)
                elseif data.params.isAction then
                    data.params.event(data.params.args)
                else
                    TriggerEvent(data.params.event, data.params.args)
                end
            end
        end
    end
end)

RegisterNUICallback('closeMenu', function()
    headerShown = false
    sendData = nil
    SetNuiFocus(false)
end)

-- Command and Keymapping

RegisterCommand('playerfocus', function()
    if headerShown then
        SetNuiFocus(true, true)
    end
end)

RegisterKeyMapping('playerFocus', 'Give Menu Focus', 'keyboard', 'LMENU')

exports('openMenu', openMenu)
exports('closeMenu', closeMenu)
exports('showHeader', showHeader)

--[[local helpNotification = false
local function RotationToDirection(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

local function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return b, c, e
end]]

local GetEntityCoords = GetEntityCoords
local Wait = Wait
local IsDisabledControlPressed = IsDisabledControlPressed
local GetEntityBoneIndexByName = GetEntityBoneIndexByName
local GetWorldPositionOfEntityBone = GetWorldPositionOfEntityBone
local SetPauseMenuActive = SetPauseMenuActive
local DisableAllControlActions = DisableAllControlActions
local EnableControlAction = EnableControlAction
local NetworkGetEntityIsNetworked = NetworkGetEntityIsNetworked
local NetworkGetNetworkIdFromEntity = NetworkGetNetworkIdFromEntity
local GetEntityModel = GetEntityModel
local IsPedAPlayer = IsPedAPlayer
local GetEntityType = GetEntityType
local PlayerPedId = PlayerPedId
local GetShapeTestResult = GetShapeTestResult
local StartShapeTestLosProbe = StartShapeTestLosProbe
local SetDrawOrigin = SetDrawOrigin
local DrawSprite = DrawSprite
local ClearDrawOrigin = ClearDrawOrigin
local HasStreamedTextureDictLoaded = HasStreamedTextureDictLoaded
local RequestStreamedTextureDict = RequestStreamedTextureDict
local currentResourceName = GetCurrentResourceName()
--local Config, Types, Players, Entities, Models, Zones, nuiData, sendData, sendDistance = Config, {{}, {}, {}}, {}, {}, {}, {}, {}, {}, {}
local playerPed, targetActive, hasFocus, success, pedsReady, allowTarget = PlayerPedId(), false, false, false, false, true
local screen = {}
screen.ratio = GetAspectRatio(true)
screen.fov = GetFinalRenderedCamFov()
local table_wipe = table.wipe
local pairs = pairs
local CheckOptions
local listSprite = {}


---------------------------------------
--- Source: https://github.com/citizenfx/lua/blob/luaglm-dev/cfx/libs/scripts/examples/scripting_gta.lua
--- Credits to gottfriedleibniz
local glm = require 'glm'

-- Cache common functions
local glm_rad = glm.rad
local glm_quatEuler = glm.quatEulerAngleZYX
local glm_rayPicking = glm.rayPicking

-- Cache direction vectors
local glm_up = glm.up()
local glm_forward = glm.forward()

local function ScreenPositionToCameraRay()
    local pos = GetFinalRenderedCamCoord()
    local rot = glm_rad(GetFinalRenderedCamRot(2))
    local q = glm_quatEuler(rot.z, rot.y, rot.x)
    return pos, glm_rayPicking(
        q * glm_forward,
        q * glm_up,
        glm_rad(screen.fov),
        screen.ratio,
        0.10000, -- GetFinalRenderedCamNearClip(),
        10000.0, -- GetFinalRenderedCamFarClip(),
        0, 0
    )
end
---------------------------------------

-- Functions

local function RaycastCamera(flag, playerCoords)
	if not playerPed then playerPed = PlayerPedId() end
	if not playerCoords then playerCoords = GetEntityCoords(playerPed) end

	local rayPos, rayDir = ScreenPositionToCameraRay()
	local destination = rayPos + 10000 * rayDir
	local rayHandle = StartShapeTestLosProbe(rayPos.x, rayPos.y, rayPos.z, destination.x, destination.y, destination.z, flag or -1, playerPed, 0)

	while true do
		local result, _, endCoords, _, entityHit = GetShapeTestResult(rayHandle)

		if result ~= 1 then
			local distance = playerCoords and #(playerCoords - endCoords)
			return endCoords, distance, entityHit, entityHit and GetEntityType(entityHit) or 0
		end

		Wait(0)
	end
end

local function DrawText3D(x, y, z, text)
    -- Use local function instead
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local function GetCurrentEntityCoords()
    --print(entityID)
    local entityCoord = GetEntityCoords(entityID)
    local min, max = GetModelDimensions(GetEntityModel(entityID))
    local height = (max.y - min.y) / 2
    local onScreen, coordX, coordY = GetHudScreenPositionFromWorldPosition(entityCoord.x, entityCoord.y + height, entityCoord.z)
    return onScreen, coordX, coordY
end

Citizen.CreateThread(function()
    local wait = 200
    while true do
        Citizen.Wait(wait)
        if entityID then
            interactionKeyOpened = true
            --print("found: "..tostring(entityType))
            local onScreen, coordX, coordY = GetCurrentEntityCoords()
            wait = 0
            if not interactionKeyPressed then
                SendNUIMessage({
                    action = "SHOW_KEY",
                    coordX = coordX,
                    coordY = coordY
                })
            else
            end
        else
            --print("not found")
            if interactionKeyOpened then
                SendNUIMessage({
                    action = "CLOSE_KEY"
                })
                wait = 200
                interactionKeyOpened = false
            end
        end
    end
end)