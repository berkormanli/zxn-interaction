entityID = nil
entityType = nil


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

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local hitCoord, distance, entityHit, type = RaycastCamera(-1, GetEntityCoords(PlayerPedId()))
        --print(hitCoord, distance, entityHit, type)
        if type ~= 0 then
            if entityHit ~= entityID then
                entityID, entityType = entityHit, type
                if type == 3 then --- Object
                    --StartObjectInteraction(entityHit)
                elseif type == 2 then --- Vehicle
                elseif type == 1 then --- Ped
                else
                    -- Do nothing for now
                end
            end
        else
            entityID = false
        end
    end
end)