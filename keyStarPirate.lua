local keyStarPirate = {}

local ship = require("ship")

local crit = 0.2
local dodge = 0.2
local armor = 2
local hp = 70
local numAmmo = 5

local function oneOrTwo()
    local roll = math.random(0, 1)
    if roll == 1 then
        return 2
    else
        return 1
    end
end

local function getRandomGun(weapons)
    local specialWeapons = {}
    if not weapons["debuff"] then
        table.insert(specialWeapons, "debuff")
    end
    if not weapons["crit"] then
        table.insert(specialWeapons, "crit")
    end
    if not weapons["pierce"] then
        table.insert(specialWeapons, "pierce")
    end

    local roll = math.random(1, table.getn(specialWeapons))
    local receivedWeapon = specialWeapons[roll]
    weapons[receivedWeapon] = true
end

local KeyStarPirate = {}

function KeyStarPirate:new()
    print("New KeyStarPirate\n")
    local weapons = {}
    getRandomGun(weapons)
    getRandomGun(weapons)

    local o = ship.newShip(dodge, crit, armor, hp, numAmmo, weapons)
    o.shipType = "keyStarPirate"
    return o
end

function keyStarPirate.newKeyStarPirate()
    return KeyStarPirate:new()
end

return keyStarPirate
