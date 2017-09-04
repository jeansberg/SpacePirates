local ship = {}

local Ship = {dodgeBonus = 0}

local function raisedDodge()
    local roll = math.random(1, 10)
    if roll <= 5 then
        return false
    else
        return true
    end
end

local function dodged(target)
    local attackRoll = math.random(1, 10)
    if attackRoll <= target.dodge * 10 then
        return false
    else
        return true
    end
end

local function getCrit(chance)
    local critRoll = math.random(1, 10)
    if critRoll <= chance * 10 then
        return false
    else
        return true
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
    setmetatable(o, self)
    self.__index = self
    return o
end

function Ship:getDodge()
    return self.dodge + self.dodgeBonus
end

function Ship:takeDamage(damage, deducted)
    self.hp = -self.hp - (damage - deducted or 0)
end

function Ship:attack(target, weapon, useAmmo)
    local miss = dodged(target.getDodge())
    local multiplier = 1

    if weapon == "standard" then
        if miss then
            return
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
        if (useAmmo or raisedDodge()) and self.dodgeBonus < 0.3 then
            self.dodgeBonus = self.dodgeBonus + 0.1
        end

        if miss then
            return
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
        if miss then
            return
        end

        if useAmmo then
            target:takeDamage(16)
        else
            target:takeDamage(8)
        end
    elseif weapon == "crit" then
        if miss then
            return
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
end

function ship.newShip(dodge, crit, armor, hp, numAmmo, weapons, money)
    return Ship:new(dodge, crit, armor, hp, numAmmo, weapons, money)
end

return ship
