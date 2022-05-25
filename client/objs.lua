objBoxZones = {}

check = false

Citizen.CreateThread(function()
    local objs = GetGamePool('CObject')
    print(GetEntityModel(objs[1]))
    for i = 1, #objs do
        if GetEntityModel(objs[i]) == 1211559620 then
            local objCoords = GetEntityCoords(objs[i])
            local boxZone = BoxZone:Create(objCoords, 5.0, 5.0, {
                name= "box_"..i,
                --offset={0.0, 0.0, 0.0},
                --scale={1.0, 1.0, 1.0},
                minZ = objCoords.z - 1.0,
                maxZ = objCoords.z + 2.0,
                debugPoly=false,
            })

            boxZone:onPlayerInOut(function(isPointInside)
                if isPointInside then
                    check = true
                    startRayCast(objs[i])
                else
                    check = false
                end
            end)


            objBoxZones[i] = {
                zone = boxZone,
                created = true
            }
        end
    end

    
end)