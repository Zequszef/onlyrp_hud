ESX = nil
local directions = { [0] = 'N', [45] = 'NW', [90] = 'W', [135] = 'SW', [180] = 'S', [225] = 'SE', [270] = 'E', [315] = 'NE', [360] = 'N', } 

CreateThread(function()
	while ESX == nil do
		TriggerEvent('hypex:getTwojStarySharedTwojaStaraObject', function(obj) ESX = obj end)
		Citizen.Wait(250)
	end

    SendNUIMessage({
        action = 'setId',
        data = GetPlayerServerId(PlayerId())
    })

end)

Citizen.CreateThread(function()
    local minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(true, false)
    Wait(5)
    SetRadarBigmapEnabled(false, true)
	SetRadarZoom(1200)
    while true do
        Wait(5)
        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
		SetRadarBigmapEnabled(false, true)
		SetRadarZoom(1200)
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)

CreateThread(function()
    while true do
        Wait(400)
        local state = NetworkIsPlayerTalking(PlayerId())
        local mode = 'Normal'
        if NetworkGetTalkerProximity() == 1.5 then
            mode = 'Whisper'
        elseif NetworkGetTalkerProximity() == 4.0 then
            mode = 'Normal'
        elseif NetworkGetTalkerProximity() == 15.0 then
            mode = 'Shouting'
        end

        SendNUIMessage({
            type = 'UPDATE_VOICE',
            isTalking = state,
            mode = mode
        })
    end
end)

CreateThread(function()
    while true do
        Wait(100)
        if IsPedInAnyVehicle(PlayerPedId()) and not IsPauseMenuActive() then
            Wait(100)
            local PedCar = GetVehiclePedIsUsing(PlayerPedId(), false)
            Speed = math.floor(GetEntitySpeed(PedCar) * 3.6 + 0.5)
            MaxSpeed = math.ceil(GetVehicleEstimatedMaxSpeed(PedCar) * 3.6 + 0.5)
            SpeedPercent = Speed / MaxSpeed * 100
            rpm = GetVehicleCurrentRpm(PedCar) * 100

			SendNUIMessage({
                type = 'SHOW_CARHUD',
                speedometer = true,
				speed = Speed,
				percent = SpeedPercent,
				rpmx = rpm,
			})
        else
            Citizen.Wait(1000)

            SendNUIMessage({
                type = 'HIDE_CARHUD'
			})
        end
    end
end)
radardisplayed = true
CreateThread(function()
    while true do
        Wait(450)
        if IsPedInAnyVehicle(PlayerPedId()) and not IsPauseMenuActive() then
            radardisplayed = true
			DisplayRadar(true)
            local PedCar = GetVehiclePedIsUsing(PlayerPedId(), false)
			local coords = GetEntityCoords(PlayerPedId())

			SetMapZoomDataLevel(0, 0.96, 0.9, 0.08, 0.0, 0.0) -- Level 0
			SetMapZoomDataLevel(1, 1.6, 0.9, 0.08, 0.0, 0.0) -- Level 1
			SetMapZoomDataLevel(2, 8.6, 0.9, 0.08, 0.0, 0.0) -- Level 2
			SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0) -- Level 3
			SetMapZoomDataLevel(4, 22.3, 0.9, 0.08, 0.0, 0.0) -- Level 4
				
		else
			SendNUIMessage({
				showhud = false
			})
            if exports["gcphone"]:getMenuIsOpen() then
                DisplayRadar(true)
                radardisplayed = true
            else
                DisplayRadar(false)
                radardisplayed = false
            end
			Wait(2000)
		end   
	end
end)

function RadarShown()
    return radardisplayed
end

local hash1, hash2;
CreateThread(function() 
    while true do
        Wait(500)
        local ped, direction = PlayerPedId(), nil
        for k, v in pairs(directions) do
            direction = GetEntityHeading(ped)
            if math.abs(direction - k) < 22.5 then
                direction = v
                break
            end
        end
        local coords = GetEntityCoords(ped, true)
        local zone = GetNameOfZone(coords.x, coords.y, coords.z)
        local zoneLabel = GetLabelText(zone)
        local var1, var2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
        hash1 = GetStreetNameFromHashKey(var1);
		hash2 = GetStreetNameFromHashKey(var2);
        local street2;
        if (hash2 == '') then
			street2 = zoneLabel;
		else
			street2 = hash2..', '..zoneLabel;
		end
        SendNUIMessage({
            street = street2,
			direction = (direction or 'N'),
			direction2 = direction .. ' | ' .. street2,
        })   
    end    
end)

CreateThread(function()
    while true do
        Wait(1000)
        local armor = GetPedArmour(PlayerPedId())
        local hp = GetEntityHealth(PlayerPedId()) - 100
		local nurkowanie = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10
        SendNUIMessage({
            type = 'UPDATE_HUD',
            armor = armor,
            nurkowanie = nurkowanie,
            zycie = hp,
            isdead = hp <= 0
        })
    end
end)

RegisterNetEvent("hud:Speedo", function(b) 
    SendNUIMessage({
        type = "HIDE_SPEDDO",
        bool = b
    })
end)

RegisterCommand("edithud", function(source, args, raw)
	SendNUIMessage({ action = 'show_hud' })
	SetNuiFocus(true, true)
	cameraLocked = true -- wyjebac
end)

RegisterNUICallback("stopedit", function()
	SetNuiFocus(false, false)
	cameraLocked = false -- wyjebac
end)