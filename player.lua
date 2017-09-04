local player = {}

local ship = require("ship")

local dodge = 0.1
local crit = 0.05
local armor = 0
local hp = 250
local numAmmo = 2
local weapons = {standardCannon = true}
local money = 20

local Player = {}

function Player:new()
    local o = ship.newShip(dodge, crit, armor, hp, numAmmo, weapons, money)
    setmetatable(o, self)
    self.__index = self
    return o
end

function Player:addWeapon(weaponName)
    self.weapons[weaponName] = true
end

function player.newPlayer()
    return Player:new()
end

return player
