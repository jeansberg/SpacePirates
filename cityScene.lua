local resources = require("resources")
local input = require("input")
local utility = require("utility")
local combatBackground = resources.images.cityScene

--[[
    City scene module.
    Code for handling city visits.
]]
local cityScene = {}

cityScene.buttons = {
    utility.newButton(
        40,
        700,
        "Exit",
        true,
        true,
        function()
            cityScene.exitScene()
        end,
        "smallFont"
    )
}

function cityScene.init(exitScene)
    cityScene.exitScene = exitScene
end

--[[
    City scene class.
]]
local CityScene = {buttons = cityScene.buttons}

function CityScene:new(node, player)
    local o = {}
    o.upgrades = node.upgrades
    o.weapons = node.weapons
    setmetatable(o, self)
    self.__index = self
    return o
end

function CityScene:draw()
    --love.graphics.draw(cityBackground, 0, 0)

    utility.drawButtons(self.buttons)

    for i = 1, table.getn(self.upgrades) do
        local upgrade = self.upgrades[i]
        love.graphics.print(upgrade, 100, 100 + i * 20)
    end

    for k, v in pairs(self.weapons) do
        love.graphics.print(k, 100, 200)
    end
end

function CityScene:update(dt)
    utility.updateButtons(self.buttons)
end

function cityScene.newCityScene(node, player)
    return CityScene:new(node, player)
end

return cityScene
