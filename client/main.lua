

QBCore = exports['qb-core']:GetCoreObject()

local currentRegister = 0
local currentSafe = 0
local copsCalled = false
local CurrentCops = 0
local PlayerJob = {}
local usingAdvanced = false
local SafeCracked = false
local Cracked = false
local openingDoor = false

--// THREADS \\ --
CreateThread(function()
    for k, _ in pairs(Config.Safes) do
        exports['qb-target']:AddCircleZone(Config.Safes[k], vector3(Config.Safes[k][1].xyz), 1.0, {
            name = Config.Safes[k],
            debugPoly = false,
        }, {
            options = {
                {
                    type = "client",
                    event = "R-L-storerobbery:client:checkmoney",
                    icon = "fas fa-lock",
                    label = "Break Open Safe",
                },
                {
                    type = "client",
                    event = "R-L-storerobbery:client:collectsafe",
                    icon = "fas fa-lock",
                    label = "Grab Goods",
                },
            },
            distance = 2.0
        })
    end
end)

CreateThread(function()
    Wait(1000)
    if QBCore.Functions.GetPlayerData().job ~= nil and next(QBCore.Functions.GetPlayerData().job) then
        PlayerJob = QBCore.Functions.GetPlayerData().job
    end
end)

CreateThread(function()
    while true do
        Wait(1000 * 60 * 5)
        if copsCalled then
            copsCalled = false
        end
    end
end)
--// THREADS \\ --

--// EVENTS \\ --
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

RegisterNetEvent('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

RegisterNetEvent('lockpicks:UseLockpick', function(isAdvanced)
    for k, v in pairs(Config.Registers) do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local dist = #(pos - Config.Registers[k][1].xyz)
        if dist <= 1 and not Config.Registers[k].robbed then
            if CurrentCops >= Config.MinimumStoreRobberyPolice then
                currentRegister = k
                if isAdvanced then
                    local seconds = math.random(8,12)
                    local circles = math.random(2,5)
                    local success = exports['qb-lock']:StartLockPickCircle(circles, seconds, success)

                    if success then
                        if currentRegister ~= 0 then
                            TriggerServerEvent('R-L-storerobbery:server:setRegisterStatus', currentRegister)
                            local lockpickTime = math.random(60000, 120000)
                            LockpickDoorAnim(lockpickTime)
                            QBCore.Functions.Progressbar("search_register", "Emptying register..", lockpickTime, false, true, {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            }, {
                                animDict = "veh@break_in@0h@p_m_one@",
                                anim = "low_force_entry_ds",
                                flags = 16,
                            }, {}, {}, function() -- Done
                                openingDoor = false
                                ClearPedTasks(PlayerPedId())
                                TriggerServerEvent('R-L-storerobbery:server:takeMoney', currentRegister, true)            
                                currentRegister = 0
                            end, function() -- Cancel
                                openingDoor = false
                                ClearPedTasks(PlayerPedId())
                                QBCore.Functions.Notify("Process canceled..", "error")
                                currentRegister = 0
                            end)
                            CreateThread(function()
                                while openingDoor do
                                    TriggerServerEvent('hud:server:gain:stress', math.random(1, 3))
                                    Wait(10000)
                                end
                            end)
                        end
                    else
                        QBCore.Functions.Notify("You failed to lockpick the till!")
                        if usingAdvanced then
                            if math.random(1, 100) < 5 then
                                TriggerServerEvent("QBCore:Server:RemoveItem", "advancedlockpick", 1)
                                TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["advancedlockpick"], "remove")
                                TriggerServerEvent('hud:server:gain:stress', math.random(1, 2))
                                QBCore.Functions.Notify("The lockpick bent out of shape...", "error")
                            end
                        else
                            if math.random(1, 100) < 25 then
                                TriggerServerEvent("QBCore:Server:RemoveItem", "lockpick", 1)
                                TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["lockpick"], "remove")
                                TriggerServerEvent('hud:server:gain:stress', math.random(2, 4))
                                QBCore.Functions.Notify("The lockpick bent out of shape...", "error")
                            end
                        end
                        if (IsWearingHandshoes() and math.random(1, 100) <= 25) then
                            local pos = GetEntityCoords(PlayerPedId())
                            TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                            QBCore.Functions.Notify("You tore yourself on a lockpick..")
                        end
                    end
                else
                    local seconds = math.random(6,10)
                    local circles = math.random(3,5)
                    local success = exports['qb-lock']:StartLockPickCircle(circles, seconds, success)
                    if success then
                        if currentRegister ~= 0 then
                            TriggerServerEvent('R-L-storerobbery:server:setRegisterStatus', currentRegister)
                            local lockpickTime = math.random(90000, 180000)
                            LockpickDoorAnim(lockpickTime)
                            QBCore.Functions.Progressbar("search_register", "Emptying register..", lockpickTime, false, true, {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            }, {
                                animDict = "veh@break_in@0h@p_m_one@",
                                anim = "low_force_entry_ds",
                                flags = 16,
                            }, {}, {}, function() -- Done
                                openingDoor = false
                                ClearPedTasks(PlayerPedId())
                                TriggerServerEvent('R-L-storerobbery:server:takeMoney', currentRegister, true)            
                                currentRegister = 0
                            end, function() -- Cancel
                                openingDoor = false
                                ClearPedTasks(PlayerPedId())
                                QBCore.Functions.Notify("Process canceled..", "error")
                                currentRegister = 0
                            end)
                            CreateThread(function()
                                while openingDoor do
                                    TriggerServerEvent('hud:server:gain:stress', math.random(1, 3))
                                    Wait(10000)
                                end
                            end)
                        end
                    else
                        QBCore.Functions.Notify("You failed to lockpick the till!")
                        if usingAdvanced then
                            if math.random(1, 100) < 5 then
                                TriggerServerEvent("QBCore:Server:RemoveItem", "advancedlockpick", 1)
                                TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["advancedlockpick"], "remove")
                                TriggerServerEvent('hud:server:gain:stress', math.random(1, 2))
                            end
                        else
                            if math.random(1, 100) < 25 then
                                TriggerServerEvent("QBCore:Server:RemoveItem", "lockpick", 1)
                                TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["lockpick"], "remove")
                                TriggerServerEvent('hud:server:gain:stress', math.random(2, 4))
                            end
                        end
                        if (IsWearingHandshoes() and math.random(1, 100) <= 25) then
                            local pos = GetEntityCoords(PlayerPedId())
                            TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                            QBCore.Functions.Notify("You tore yourself on a lockpick..")
                        end
                    end
                end

                if not IsWearingHandshoes() then
                    TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                end
                if not copsCalled then
                    local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
                    local street1 = GetStreetNameFromHashKey(s1)
                    local street2 = GetStreetNameFromHashKey(s2)
                    local streetLabel = street1
                    if street2 ~= nil then
                        streetLabel = streetLabel .. " " .. street2
                    end
                    TriggerServerEvent("R-L-storerobbery:server:callCops", "cashier", currentRegister, streetLabel, pos)
                    copsCalled = true
                end

            else
                QBCore.Functions.Notify("Not Enough Police (".. Config.MinimumStoreRobberyPolice .." Required)", "error")
            end
        end
    end
end)

RegisterNetEvent('R-L-storerobbery:client:checkmoney', function()
    TriggerServerEvent('R-L-storerobbery:server:CheckItem')
end)

RegisterNetEvent('R-L-storerobbery:client:hacksafe', function()
    local pos = GetEntityCoords(PlayerPedId())
    for safe,_ in pairs(Config.Safes) do
        local dist = #(pos - Config.Safes[safe][1].xyz)
        if dist < 1.0 then
            if Config.Safes[safe].robbed then
                QBCore.Functions.Notify("Look's empty!", "error")
            elseif Cracked then
                QBCore.Functions.Notify("Security lock active!", "error")
            elseif not Config.Safes[safe].robbed then
                TriggerServerEvent("QBCore:Server:RemoveItem", "safecracker", 1)
                TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items["safecracker"], "remove")
                MemoryGame()
            else
                QBCore.Functions.Notify("HOW?! Contact a Staff Member", "error")
            end
        end
    end
end)

RegisterNetEvent('R-L-storerobbery:client:collectsafe', function()
    CollectSafeMoney()
end)

RegisterNetEvent('R-L-storerobbery:client:setRegisterStatus', function(batch, val)
    -- Has to be a better way maybe like adding a unique id to identify the register
    if(type(batch) ~= "table") then
        Config.Registers[batch] = val
    else
        for k, v in pairs(batch) do
            Config.Registers[k] = batch[k]
        end
    end
end)

RegisterNetEvent('R-L-storerobbery:client:setSafeStatus', function(safe, bool)
    Config.Safes[safe].robbed = bool
end)

--// EVENTS \\ --

--// FUNCTIONS \\ --
function lockpickTill()
    for k, v in pairs(Config.Registers) do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local dist = #(pos - Config.Registers[k][1].xyz)
        if dist <= 1 and not Config.Registers[k].robbed then
            if CurrentCops >= Config.MinimumStoreRobberyPolice then
                currentRegister = k
                local seconds = math.random(8,12)
                local circles = math.random(2,5)
                local success = exports['qb-lock']:StartLockPickCircle(circles, seconds, success)
                if success then
                    if currentRegister ~= 0 then
                        TriggerServerEvent('R-L-storerobbery:server:setRegisterStatus', currentRegister)
                        local lockpickTime = math.random(10000, 20000)
                        LockpickDoorAnim(lockpickTime)
                        QBCore.Functions.Progressbar("search_register", "Emptying register..", lockpickTime, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {
                            animDict = "veh@break_in@0h@p_m_one@",
                            anim = "low_force_entry_ds",
                            flags = 16,
                        }, {}, {}, function() -- Done
                            openingDoor = false
                            ClearPedTasks(PlayerPedId())
                            TriggerServerEvent('R-L-storerobbery:server:takeMoney', currentRegister, true)            
                            currentRegister = 0
                        end, function() -- Cancel
                            openingDoor = false
                            ClearPedTasks(PlayerPedId())
                            QBCore.Functions.Notify("Process canceled..", "error")
                            currentRegister = 0
                        end)
                        CreateThread(function()
                            while openingDoor do
                                TriggerServerEvent('hud:server:gain:stress', math.random(1, 3))
                                Wait(10000)
                            end
                        end)
                    end
                else
                    QBCore.Functions.Notify("You failed to lockpick the till!")
                    if (IsWearingHandshoes() and math.random(1, 100) <= 25) then
                        local pos = GetEntityCoords(PlayerPedId())
                        TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                        QBCore.Functions.Notify("You tore yourself on a lockpick..")
                    end
                end

                if not IsWearingHandshoes() then
                    TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                end

                if not copsCalled then
                    local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
                    local street1 = GetStreetNameFromHashKey(s1)
                    local street2 = GetStreetNameFromHashKey(s2)
                    local streetLabel = street1
                    if street2 ~= nil then
                        streetLabel = streetLabel .. " " .. street2
                    end
                    TriggerServerEvent("R-L-storerobbery:server:callCops", "cashier", currentRegister, streetLabel, pos)
                    copsCalled = true
                end

            else
                QBCore.Functions.Notify("Not Enough Police (".. Config.MinimumStoreRobberyPolice .." Required)", "error")
            end
        elseif dist <= 1 and Config.Registers[k].robbed then
            QBCore.Functions.Notify("This Register is empty", "error")
        end
    end
end

function IsWearingHandshoes()
    local armIndex = GetPedDrawableVariation(PlayerPedId(), 3)
    local model = GetEntityModel(PlayerPedId())
    local retval = true

    if model == GetHashKey("mp_m_freemode_01") then
        if Config.MaleNoHandshoes[armIndex] ~= nil and Config.MaleNoHandshoes[armIndex] then
            retval = false
        end
    else
        if Config.FemaleNoHandshoes[armIndex] ~= nil and Config.FemaleNoHandshoes[armIndex] then
            retval = false
        end
    end
    return retval
end

function setupRegister()
    QBCore.Functions.TriggerCallback('R-L-storerobbery:server:getRegisterStatus', function(Registers)
        for k, v in pairs(Registers) do
            Config.Registers[k].robbed = Registers[k].robbed
        end
    end)
end

function setupSafes()
    QBCore.Functions.TriggerCallback('R-L-storerobbery:server:getSafeStatus', function(Safes)
        for k, v in pairs(Safes) do
            Config.Safes[k].robbed = Safes[k].robbed
        end
    end)
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(100)
    end
end

function takeAnim()
    local ped = PlayerPedId()
    while (not HasAnimDictLoaded("amb@prop_human_bum_bin@idle_b")) do
        RequestAnimDict("amb@prop_human_bum_bin@idle_b")
        Wait(100)
    end
    TaskPlayAnim(ped, "amb@prop_human_bum_bin@idle_b", "idle_d", 8.0, 8.0, -1, 50, 0, false, false, false)
    Wait(2500)
    TaskPlayAnim(ped, "amb@prop_human_bum_bin@idle_b", "exit", 8.0, 8.0, -1, 50, 0, false, false, false)
end

function LockpickDoorAnim(time)
    time = time / 1000
    loadAnimDict("veh@break_in@0h@p_m_one@")
    TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds" ,3.0, 3.0, -1, 16, 0, false, false, false)
    openingDoor = true
    CreateThread(function()
        while openingDoor do
            TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 3.0, 3.0, -1, 16, 0, 0, 0, 0)
            Wait(2000)
            time = time - 2
            TriggerServerEvent('R-L-storerobbery:server:takeMoney', currentRegister, false)
            if time <= 0 then
                openingDoor = false
                StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
            end
        end
    end)
end

function MemoryGame()
    local pos = GetEntityCoords(PlayerPedId())
    for safe,_ in pairs(Config.Safes) do

        local dist = #(pos - Config.Safes[safe][1].xyz)

        if dist < 3 then
            if dist < 1.0 then

                if not Config.Safes[safe].robbed and not SafeCracked then
                    if CurrentCops >= Config.MinimumStoreRobberyPolice then

                        currentSafe = safe

                        if math.random(1, 100) <= 65 and not IsWearingHandshoes() then
                            TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                        end
                        
                        -- // MINI GAME \\ --
                        exports["memorygame_2"]:thermiteminigame(6, 3, 2, 20,
                        function() -- Success

                            if math.random(1, 100) <= 35 then
                                TriggerServerEvent('hud:server:gain:stress', math.random(5, 8))
                            end

                            Cracked = true
                            copsCalled = false

                            if currentSafe ~= 0 then
                                if not Config.Safes[currentSafe].robbed then
                                    QBCore.Functions.Notify("Safe Cracked, wait nearby!")
                                    Wait(300000)
                                    if dist < 50 then
                                        SafeCracked = true
                                        Cracked = false
                                        QBCore.Functions.Notify("Go grab the loot", "success")
                                    else
                                        SafeCracked = false
                                        Cracked = false
                                        QBCore.Functions.Notify("Moved too far from the safe!")
                                    end
                                end
                            end

                        end,

                        function() -- Failure

                            if math.random(1, 100) <= 75 then
                                TriggerServerEvent('hud:server:gain:stress', math.random(8, 15))
                            end

                            SafeCracked = false
                            Cracked = false
                            QBCore.Functions.Notify("You failed!")

                        end)

                        -- // MINI GAME \\ --

                        if not copsCalled then
                            local pos = GetEntityCoords(PlayerPedId())
                            local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
                            local street1 = GetStreetNameFromHashKey(s1)
                            local street2 = GetStreetNameFromHashKey(s2)
                            local streetLabel = street1
                            if street2 ~= nil then
                                streetLabel = streetLabel .. " " .. street2
                            end
                            TriggerServerEvent("R-L-storerobbery:server:callCops", "safe", currentSafe, streetLabel, pos)
                            copsCalled = true
                        end
                    else
                        QBCore.Functions.Notify("Not Enough Police (".. Config.MinimumStoreRobberyPolice .." Required)", "error")
                    end
                else
                    QBCore.Functions.Notify("Already Opened", "error")
                end

            end
        end

    end
end

function CollectSafeMoney()
    local pos = GetEntityCoords(PlayerPedId())
    for safe, _ in pairs(Config.Safes) do
        local dist = #(pos - Config.Safes[safe][1].xyz)
        if dist < 3 then
            if dist < 1.0 then
                if SafeCracked then
                    if CurrentCops >= Config.MinimumStoreRobberyPolice then
                        currentSafe = safe
                        -- // FINGYPRINTS \\ --
                        if math.random(1, 100) <= 65 and not IsWearingHandshoes() then
                            TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                        end
                        -- // COLLECTION \\ --
                        if currentSafe ~= 0 then
                            if SafeCracked then
                                TriggerServerEvent("R-L-storerobbery:server:SafeReward", currentSafe)
                                TriggerServerEvent("R-L-storerobbery:server:setSafeStatus", currentSafe)
                                currentSafe = 0
                                QBCore.Functions.Notify("Grabbed the loot", "success")
                                takeAnim()
                                SafeCracked = false
                                Cracked = false
                            else
                                QBCore.Functions.Notify("It's still locked!", "error")
                                SafeCracked = false
                                Cracked = false
                            end
                        end
                        -- // COLLECTION \\ --
                    else
                        QBCore.Functions.Notify("Not Enough Police (".. Config.MinimumStoreRobberyPolice .." Required)", "error")
                    end
                else
                    QBCore.Functions.Notify("Safe appears broken!", "error")
                end
            end
        end
    end
end
--// FUNCTIONS \\ --