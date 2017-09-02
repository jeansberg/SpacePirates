local resources = require("resources")
local combatBackground = resources.images.combatScene

--[[
    Combat scene module.
    Code for handling combat encounters.
]]

local combatScene = {}

--[[
    Combat scene class.
]]

local CombatScene = {}

function CombatScene:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function CombatScene:draw()
    love.graphics.draw(combatBackground, 0, 0)
end

function CombatScene:update(dt)

end

function combatScene.newCombatScene()
    return CombatScene:new()
end

return combatScene