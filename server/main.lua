

QBCore = exports['qb-core']:GetCoreObject()

local cashA = 750 				--<<how much minimum you can get from a robbery
local cashB = 1500				--<< how much maximum you can get from a robbery
local ScashA = 2000 			--<<how much minimum you can get from a robbery
local ScashB = 3500				--<< how much maximum you can get from a robbery

RegisterServerEvent('R-L-storerobbery:server:takeMoney')
AddEventHandler('R-L-storerobbery:server:takeMoney', function(register, isDone)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	-- Add some stuff if you want, this here above the if statement will trigger every 2 seconds of the animation when robbing a cash register.
    if isDone then
	local bags = math.random(1,3)
	local info = {
		worth = math.random(cashA, cashB)
	}
	Player.Functions.AddItem('markedbills', bags, false, info)
	TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['markedbills'], "add")
        if math.random(1, 100) <= 10 then
            -- Give Special Item (Safe Cracker)
            Player.Functions.AddItem("safecracker", 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["safecracker"], 'add')
        end
    end
end)

RegisterServerEvent('R-L-storerobbery:server:setRegisterStatus')
AddEventHandler('R-L-storerobbery:server:setRegisterStatus', function(register)
    Config.Registers[register].robbed   = true
    Config.Registers[register].time     = Config.resetTime
    TriggerClientEvent('R-L-storerobbery:client:setRegisterStatus', -1, register, Config.Registers[register])
end)

RegisterServerEvent('R-L-storerobbery:server:setSafeStatus')
AddEventHandler('R-L-storerobbery:server:setSafeStatus', function(safe)
    TriggerClientEvent('R-L-storerobbery:client:setSafeStatus', -1, safe, true)
    Config.Safes[safe].robbed = true

    SetTimeout(math.random(40, 80) * (60 * 1000), function()
        TriggerClientEvent('R-L-storerobbery:client:setSafeStatus', -1, safe, false)
        Config.Safes[safe].robbed = false
    end)
end)

RegisterServerEvent('R-L-storerobbery:server:SafeReward')
AddEventHandler('R-L-storerobbery:server:SafeReward', function(safe)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local bags = math.random(2,5)
	local info = {
		worth = math.random(ScashA, ScashB)
	}
	Player.Functions.AddItem('markedbills', bags, false, info)
	TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['markedbills'], "add")
    local luck = math.random(1, 100)
    local odd = math.random(1, 100)
    if luck <= 10 then
            Player.Functions.AddItem("rolex", 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["rolex"], "add")
        if luck == odd then
            Citizen.Wait(500)
            Player.Functions.AddItem("goldbar", 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["goldbar"], "add")
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        local toSend = {}
        for k, v in ipairs(Config.Registers) do

            if Config.Registers[k].time > 0 and (Config.Registers[k].time - Config.tickInterval) >= 0 then
                Config.Registers[k].time = Config.Registers[k].time - Config.tickInterval
            else
                if Config.Registers[k].robbed then
                    Config.Registers[k].time = 0
                    Config.Registers[k].robbed = false

                    table.insert(toSend, Config.Registers[k])
                end
            end
        end

        if #toSend > 0 then
            --The false on the end of this is redundant
            TriggerClientEvent('R-L-storerobbery:client:setRegisterStatus', -1, toSend, false)
        end

        Citizen.Wait(Config.tickInterval)
    end
end)

QBCore.Functions.CreateCallback('R-L-storerobbery:server:getRegisterStatus', function(source, cb)
    cb(Config.Registers)
end)

QBCore.Functions.CreateCallback('R-L-storerobbery:server:getSafeStatus', function(source, cb)
    cb(Config.Safes)
end)

RegisterServerEvent('R-L-storerobbery:server:CheckItem')
AddEventHandler('R-L-storerobbery:server:CheckItem', function()
    local Player = QBCore.Functions.GetPlayer(source)
    local ItemData = Player.Functions.GetItemByName("safecracker")
    if ItemData ~= nil then
        TriggerClientEvent('R-L-storerobbery:client:hacksafe', source)
    else
        TriggerClientEvent('QBCore:Notify', source, "You appear to be missing something?")
    end
end)

RegisterServerEvent('R-L-storerobbery:server:callCops')
AddEventHandler('R-L-storerobbery:server:callCops', function(type, safe, streetLabel, coords)

    local cameraId = 4
    if type == "safe" then
        cameraId = Config.Safes[safe].camId
    else
        cameraId = Config.Registers[safe].camId
    end

    TriggerClientEvent("dispatch:storerobbery", -1, coords, cameraId) -- Project Sloth Dispatch

    -- // QB PHONE PD ALERT \\ --
    local alertData = {
        title = "10-90 | Shop Robbery",
        coords = {x = coords.x, y = coords.y, z = coords.z},
        description = "Someone Is Trying To Rob A Store At "..streetLabel.." (CAMERA ID: "..cameraId..")"
    }
    TriggerClientEvent("qb-phone:client:addPoliceAlert", -1, alertData)
    
end)