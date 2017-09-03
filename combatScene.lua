local resources = require("resources")
local input = require("input")
local combatBackground = resources.images.combatScene

--[[
    Combat scene module.
    Code for handling combat encounters.
]]
local combatScene = {}
combatScene.backButton = {
    active = false,
    text = "Back",
    rect = {xPos = 40, yPos = 700, width = 50, height = 40}
}
--[[
    Combat scene class.
]]
local CombatScene = {}

function CombatScene:new(exitCombat)
    local o = {exitCombat = exitCombat}
    setmetatable(o, self)
    self.__index = self
    return o
end

function CombatScene:draw()
    love.graphics.draw(combatBackground, 0, 0)
    local printFunction =
        function()
        love.graphics.print(
            combatScene.backButton.text,
            combatScene.backButton.rect.xPos,
            combatScene.backButton.rect.yPos
        )
    end
    if combatScene.backButton.active then
        resources.drawWithColor(
            255,
            0,
            0,
            255,
            function()
                resources.printWithFont("smallFont", printFunction)
            end
        )
    else
        resources.printWithFont("smallFont", printFunction)
    end
end

function CombatScene:update(dt)
    if input.mouseOver(combatScene.backButton.rect) then
        combatScene.backButton.active = true
        if input.getLeftClick() then
            self.exitCombat()
        end
    else
        combatScene.backButton.active = false
    end
end

function combatScene.newCombatScene(exitCombat)
    return CombatScene:new(exitCombat)
end

return combatScene
