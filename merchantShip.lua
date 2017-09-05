local merchantShip = {}

local ship = require("ship")

local crit = 0.15
local dodge = 0.2
local numAmmo = 3
local armor = 1
local hp = 55
local weapons = {standardCannon = true}

local function getRandomGun()
    local roll = math.random(1, 3)
    if roll == 1 then
        return "debuff"
    elseif roll == 2 then
        return "crit"
    elseif roll == 2 then
        return "pierce"
    end
end

local MerchantShip = {}

function MerchantShip:new()
    weapons[getRandomGun()] = true

    local o = ship.newShip(dodge, crit, armor, hp, numAmmo, weapons)
    o.shipType = "merchantShip"
    return o
end

function MerchantShip:addWeapon(weaponName)
    self.weapons[weaponName] = true
end

function merchantShip.newMerchantShip()
    return MerchantShip:new()
end

return merchantShip