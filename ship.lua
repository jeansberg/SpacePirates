local ship = {}

local Ship = {dodgeBonus = 0}

local resources = require("resources")
local laserShot = resources.sounds.laserShot
local critCannon = resources.sounds.critCannon
local debuffAttack = resources.sounds.debuffAttack
local dodgeSound = resources.sounds.dodge
local damageSound = resources.sounds.damage2
local shipDestroyed = resources.sounds.shipDestroyed
local lowHealth = resources.sounds.lowHealth

local function raisedDodge()
    local roll = math.random(1, 10)
    if roll <= 5 then
        return false
    else
        return true
    end
end

local function dodged(dodge)
    local attackRoll = math.random(1, 100)
    if attackRoll <= dodge * 100 then
        resources.playSound(dodgeSound)
        return true
    else
        return false
    end
end

local function getCrit(chance)
    local critRoll = math.random(1, 100)
    if critRoll <= chance * 100 then
        return true
    else
        return false
    end
end

function Ship:new(dodge, crit, armor, hp, numAmmo, weapons, money)
    local o = {
        dodge = dodge,
        crit = crit,
        armor = armor,
        hp = hp,
        numAmmo = numAmmo,
        weapons = weapons,
        money = money or 0
    }
    o.weapons["standard"] = true
    setmetatable(o, self)
    self.__index = self
    return o
end

function Ship:getDodge()
    return self.dodge + self.dodgeBonus
end

function Ship:takeDamage(damage, deducted)
    local finalDamage = (damage - (deducted or 0))
    self.hp = self.hp - finalDamage

    if (finalDamage > 0) then
        resources.playSound(damageSound)
    end

    if self.hp < 1 then
        resources.playSound(shipDestroyed)
    end
end

function Ship:attack(target, weapon, useAmmo)
    if useAmmo then
        self.numAmmo = self.numAmmo - 1
    end

    local miss = dodged(target:getDodge())
    local multiplier = 1

    if weapon == "standard" then
        resources.playSound(laserShot)
        if miss then
            return false
        end
        if getCrit(self.crit) then
            multiplier = 2
        end

        if useAmmo then
            target:takeDamage(16 * multiplier, target.armor)
        else
            target:takeDamage(8 * multiplier, target.armor)
        end
    elseif weapon == "debuff" then
        resources.playSound(debuffAttack)
        if (useAmmo or raisedDodge()) and self.dodgeBonus < 0.3 then
            self.dodgeBonus = self.dodgeBonus + 0.1
        end

        if miss then
            return false
        end
        if getCrit(self.crit) then
            multiplier = 2
        end

        if useAmmo then
            target:takeDamage(8 * multiplier, target.armor)
        else
            target:takeDamage(4 * multiplier, target.armor)
        end
    elseif weapon == "pierce" then
        resources.playSound(laserShot)
        if miss then
            return false
        end

        if useAmmo then
            target:takeDamage(16)
        else
            target:takeDamage(8)
        end
    elseif weapon == "crit" then
        resources.playSound(critCannon)
        if miss then
            return false
        end

        if useAmmo then
            if getCrit(self.crit + 0.45) then
                multiplier = 2
            end
            target:takeDamage(12 * multiplier, target.armor)
        else
            if getCrit(self.crit + 0.2) then
                multiplier = 2
            end
            target:takeDamage(6 * multiplier, target.armor)
        end
    end

    return true
end

function ship.getRandomGun(weapons)
    roll = math.random(1, 3)
    if roll == 1 then
        weapons["debuff"] = true
    elseif roll == 2 then
        weapons["crit"] = true
    elseif roll == 2 then
        weapons["pierce"] = true
    end
end

function ship.getRandomGunMaybe(weapons)
    local roll = math.random(0, 1)
    if roll == 0 then
        return
    else
        roll = math.random(1, 3)
        if roll == 1 then
            weapons["debuff"] = true
        elseif roll == 2 then
            weapons["crit"] = true
        elseif roll == 2 then
            weapons["pierce"] = true
        end
    end
end

function ship.newShip(dodge, crit, armor, hp, numAmmo, weapons, money)
    return Ship:new(dodge, crit, armor, hp, numAmmo, weapons, money)
end

return ship
