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

function loot.getLoot(player, enemy, type)
    local lootReturn = {}
    if enemy.shipType == "pirate" then
        if type == "surrender" then
            getMoney(lootReturn, player, 10, 10)
            getUpgrade(lootReturn, player, 0.05)
            getAmmo(lootReturn, player, 1, 1, 0.5)
            getWeapon(lootReturn, player, 0.01)
        else
            getMoney(lootReturn, player, 10, 20)
            getUpgrade(lootReturn, player, 0.1)
            getAmmo(lootReturn, player, 1, 2, 1)
            getWeapon(lootReturn, player, 0.05)
        end
    end

    return lootReturn
end

return loot
