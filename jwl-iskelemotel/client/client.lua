QBCore = exports['qb-core']:GetCoreObject()

local currentmotel = nil
local inroom = false
local pinkcagecoord = vector3(-1845.02, -1195.49, 19.184)

local roomCoord = vector3(-1232.2, 3874.42, 154.114)
local roomHeading = 67.57
local stashCoord = vector3(-1231.6, 3878.42, 154.114)
local clotheCoord = vector3(-1236.0, 3880.17, 154.114)

local pinkcage = {
    [1] = vector3(-1845.02, -1195.49, 19.184),
}

RegisterNetEvent('QBCore:Client:OnPlayerLoadedesx:playerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    currentmotel = math.random(1, #pinkcage)
 --   notify('inform', 'Yeni motel odası verildi! Oda numaran: '..currentmotel)
end)

RegisterCommand('yenimotelodasi', function()
    currentmotel = math.random(1, #pinkcage)
 --   notify('inform', 'Yeni motel odası verildi! Oda numaran: '..currentmotel)
end)

Citizen.CreateThread(function()
    local gblip = AddBlipForCoord(pinkcagecoord)
    SetBlipSprite(gblip, 475)
    SetBlipDisplay(gblip, 4)
    SetBlipScale (gblip, 0.6)
    SetBlipColour(gblip, 27)
    SetBlipAsShortRange(gblip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(" Motel")
    EndTextCommandSetBlipName(gblip)
end)

Citizen.CreateThread(function()
    while true do
        local delay = false
        if currentmotel ~= nil then
            local player = PlayerPedId()
            local playercoords = GetEntityCoords(player)
            -- local stashdistance = #(playercoords - pinkcage[currentmotel].stash)
            -- local clothedistance = #(playercoords - pinkcage[currentmotel].clothe)
            local doordistance = GetDistanceBetweenCoords(playercoords, pinkcage[currentmotel], true)
            local moteldistance = GetDistanceBetweenCoords(playercoords, pinkcagecoord, true)

            if moteldistance <= 60.0 then
                if doordistance <= 30.0 then
                    DrawMarker(22, pinkcage[currentmotel].x, pinkcage[currentmotel].y, pinkcage[currentmotel].z - 0.3, 0, 0, 0, 0, 0, 0, 0.3, 0.3, 0.3, 32, 236, 54, 255, 0, 0, 0, 1, 0, 0, 0)
                end
                if doordistance <= 2.0 then
                    DrawText3D(pinkcage[currentmotel], "[~g~E~w~] - Motel odana gir")
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('jwl:motel:server:enterMotelRoom')
                    end
                end
            elseif inroom then
                local stashdistance = GetDistanceBetweenCoords(playercoords, stashCoord, true)
                local clothedistance = GetDistanceBetweenCoords(playercoords, clotheCoord, true)
                local exitdistance = GetDistanceBetweenCoords(playercoords, roomCoord, true)
                if stashdistance <= 1.5 then
                    DrawText3D(stashCoord, '[~g~E~w~] - Sandık')
                    if IsControlJustReleased(0, 38) then
                        OpenMotelInventory()
                    end
                end
                if clothedistance <= 1.5 then
                    DrawText3D(clotheCoord, '[~g~E~w~] - Gardrop')
                    if IsControlJustReleased(0, 38) then
                        OpenMotelWardrobe()
                    end
                end
                if exitdistance <= 1.5 then
                    DrawText3D(roomCoord, '[~g~E~w~] - Ayrıl')
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('jwl:motel:server:exitMotelRoom')
                    end
                end
            else
                delay = true
            end
        else
            delay = true
        end

        if delay then
            Citizen.Wait(500)
        end
        Citizen.Wait(5)
    end
end)

RegisterNetEvent('jwl:motel:client:enterMotelRoom')
AddEventHandler('jwl:motel:client:enterMotelRoom', function()
    local player = PlayerPedId()
    DoScreenFadeOut(500)
    Wait(600)
    FreezeEntityPosition(player, true)
    SetEntityCoords(player, roomCoord.x, roomCoord.y, roomCoord.z-1.0)
    SetEntityHeading(player, roomHeading)
    Wait(1400)
    inroom = true
    DoScreenFadeIn(1000)
    repeat
        Citizen.Wait(10)
	until (IsControlJustPressed(0, 32) or IsControlJustPressed(0, 33) or IsControlJustPressed(0, 34) or IsControlJustPressed(0, 35))

    FreezeEntityPosition(player, false)
end)

RegisterNetEvent('jwl:motel:client:exitMotelRoom')
AddEventHandler('jwl:motel:client:exitMotelRoom', function()
    local player = PlayerPedId()
    DoScreenFadeOut(500)
    Wait(1500)
    SetEntityCoords(player, pinkcage[currentmotel].x, pinkcage[currentmotel].y, pinkcage[currentmotel].z-1)
    Wait(500)
    inroom = false
    DoScreenFadeIn(1000)
end)

function OpenMotelWardrobe()
    TriggerEvent('qb-clothing:client:openOutfitMenu')
end

function OpenMotelInventory()
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "motelstash_"..QBCore.Functions.GetPlayerData().citizenid)
    TriggerEvent("inventory:client:SetCurrentStash", "motelstash_"..QBCore.Functions.GetPlayerData().citizenid)
end

function notify(type, text, time)
    if length == nil then length = 5000 end 
    TriggerEvent('mythic_notify:client:SendAlert', { type = type, text = text, length = length})
end

function DrawText3D(coord, text)
	local onScreen,_x,_y=GetScreenCoordFromWorldCoord(coord.x, coord.y, coord.z)
	local px,py,pz=table.unpack(GetGameplayCamCoords()) 
	local scale = 0.3
	if onScreen then
		SetTextScale(scale, scale)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextDropshadow(0)
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
        DrawText(_x,_y)
        local factor = (string.len(text)) / 380
        DrawRect(_x, _y + 0.0120, 0.0 + factor, 0.025, 41, 11, 41, 100)
	end
end