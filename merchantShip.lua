local merchantShip = {}

local ship = require("ship")

local crit = 0.15
local dodge = 0.2
local numAmmo = 3
local armor = 2
local hp = 55

local function getRandomGun(weapons)
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

local MerchantShip = {}

function MerchantShip:new()
    print("New MerchantShip\n")
    local weapons = {}
    getRandomGun(weapons)

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
