local resources = require("resources")
local input = require("input")
local utility = require("utility")
local combatBackground = resources.images.cityScene

--[[
    City scene module.
    Code for handling city visits.
]]
local cityScene = {}
function cityScene.init(exitScene)
    cityScene.exitScene = exitScene
end

--[[
    City scene class.
]]
local CityScene = {}
CityScene.buttons = {
    utility.newButton(
        40,
        700,
        "Back",
        true,
        function()
            cityScene.exitScene()
        end,
        "smallFont"
    )
}

function CityScene:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function CityScene:draw()
    --love.graphics.draw(cityBackground, 0, 0)

    utility.drawButtons(self.buttons)
end

function CityScene:update(dt)
    utility.updateButtons(self.buttons)
end

function cityScene.newCityScene()
    return CityScene:new()
end

return cityScene
