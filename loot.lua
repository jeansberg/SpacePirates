local loot = {}

local function randomRoll(chance)
    local roll = math.random(1, 100)
    if roll <= chance * 100 then
        return true
    end
    return false
end

local function getMoney(lootReturn, player, min, max)
    local lootRoll = math.random(0, 1)
    local lootMoney = min
    if lootRoll == 1 then
        lootMoney = max
    end
    player.money = player.money + lootMoney
    table.insert(lootReturn, {amount = lootMoney, text = "money"})
end

local function getUpgrade(lootReturn, player, chance)
    if randomRoll(chance) then
        local roll = math.random(1, 3)
        if roll == 1 then
            player.armor = player.armor + 1
            table.insert(lootReturn, {amount = 1, text = "armor point"})
        elseif roll == 2 and player.crit < 1 then
            player.crit = player.crit + 0.1
            table.insert(lootReturn, {amount = 10, text = "% crit bonus"})
        elseif roll == 3 and player.dodge < 1 then
            player.dodge = player.dodge + 0.1
            table.insert(lootReturn, {amount = 10, text = "% dodge bonus"})
        end
    end
end

local function getAmmo(lootReturn, player, min, max, chance)
    if randomRoll(chance) then
        local amount = 0
        if math.random(0, 1) == 1 then
            amount = max
        else
            amount = min
        end
        player.numAmmo = player.numAmmo + amount
        table.insert(lootReturn, {amount = amount, text = "ammo"})
    end
end

local function getWeapon(lootReturn, player, chance)
    if randomRoll(chance) then
        local specialWeapons = {}
        if not player.weapons["debuff"] then
            table.insert(specialWeapons, "debuff")
        end
        if not player.weapons["crit"] then
            table.insert(specialWeapons, "crit")
        end
        if not player.weapons["pierce"] then
            table.insert(specialWeapons, "pierce")
        end

        if table.getn(specialWeapons) == 0 then
            return
        end

        local roll = math.random(1, table.getn(specialWeapons))
        local receivedWeapon = specialWeapons[roll]
        player.weapons[receivedWeapon] = true

        if receivedWeapon == "debuff" then
            table.insert(lootReturn, {amount = 1, text = "Blinding Cannon"})
        elseif receivedWeapon == "crit" then
            table.insert(lootReturn, {amount = 1, text = "Crit Cannon"})
        elseif receivedWeapon == "pierce" then
            table.insert(lootReturn, {amount = 1, text = "Pierce Cannon"})
        end
    end
end

function loot.getLoot(player, enemy, type, extraLoot)
    local lootReturn = {}
    if enemy.shipType == "pirate" then
        if type == "surrender" then
            if extraLoot then
                getMoney(lootReturn, player, 20, 30)
            else
                getMoney(lootReturn, player, 10, 10)
            end
            if extraLoot then
                getUpgrade(lootReturn, player, 0.05)
            else
                getUpgrade(lootReturn, player, 0.15)
            end
            if extraLoot then
                getAmmo(lootReturn, player, 1, 2, 1)
            else
                getAmmo(lootReturn, player, 1, 1, 0.5)
            end
            getWeapon(lootReturn, player, 0.01)
        else
            if extraLoot then
                getMoney(lootReturn, player, 20, 40)
            else
                getMoney(lootReturn, player, 10, 20)
            end
            if extraLoot then
                getUpgrade(lootReturn, player, 0.1)
            else
                getUpgrade(lootReturn, player, 0.2)
            end
            if extraLoot then
                getAmmo(lootReturn, player, 2, 3, 1)
            else
                getAmmo(lootReturn, player, 1, 2, 1)
            end
            getWeapon(lootReturn, player, 0.05)
        end
    elseif enemy.shipType == "highLevelPirate" then
        getMoney(lootReturn, player, 30, 40)
        getUpgrade(lootReturn, player, 0.2)
        getAmmo(lootReturn, player, 2, 3, 1)
        getWeapon(lootReturn, player, 0.1)
    elseif enemy.shipType == "merchantShip" then
        getMoney(lootReturn, player, 50, 60)
        getUpgrade(lootReturn, player, 0.5)
        getAmmo(lootReturn, player, 3, 4, 1)
        getWeapon(lootReturn, player, 0.3)
    elseif enemy.shipType == "keyStarPirate" then
        getMoney(lootReturn, player, 80, 80)
        getUpgrade(lootReturn, player, 1)
        getAmmo(lootReturn, player, 5, 5, 1)
        getWeapon(lootReturn, player, 1)
    end

    return lootReturn
end

return loot
