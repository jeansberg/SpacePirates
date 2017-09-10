local merchantShip = {}

local ship = require("ship")

local crit = 0.15
local dodge = 0.2
local numAmmo = 3
local armor = 2
local hp = 60

local MerchantShip = {}

function MerchantShip:new()
    print("New MerchantShip\n")
    local weapons = {}
    ship.getRandomGun(weapons)

    local o = ship.newShip(dodge, crit, armor, hp, numAmmo, weapons)
    o.shipType = "merchantShip"
    o.maxHp = hp
    return o
end

function MerchantShip:addWeapon(weaponName)
    self.weapons[weaponName] = true
end

function merchantShip.newMerchantShip()
    return MerchantShip:new()
end

return merchantShip
