local player = {}

local ship = require("ship")

local dodge = 0.1
local crit = 0.05
local armor = 0
local hp = 250
local numAmmo = 2
local money = 20

local Player = {}

function Player:new()
    local weapons = {standardCannon = true}
    local o = ship.newShip(dodge, crit, armor, hp, numAmmo, weapons, money)
    o.shipType = "player"
    return o
end

function Player:addWeapon(weaponName)
    self.weapons[weaponName] = true
end

function player.newPlayer()
    return Player:new()
end

return player
