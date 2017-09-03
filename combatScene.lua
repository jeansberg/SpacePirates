local resources = require("resources")
local input = require("input")
local utility = require("utility")

local combatBackground = resources.images.combatScene

--[[
    Combat scene module.
    Code for handling combat encounters.
]]
local combatScene = {}
function combatScene.init(exitScene)
    combatScene.exitScene = exitScene
end

--[[
    Combat scene class.
]]
local CombatScene = {}
CombatScene.buttons = {
    {
        name = "backButton",
        active = false,
        text = "Back",
        rect = utility.rect(40, 700, 50, 40),
        activate = function()
            combatScene.exitScene()
        end
    }
}

function CombatScene:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

local function drawButtons(buttons)
    local button = {}
    local printFunction = function()
        love.graphics.print(button.text, button.rect.xPos, button.rect.yPos)
    end

    for i = 1, table.getn(buttons) do
        button = buttons[i]
        if button.active then
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
end

function CombatScene:draw()
    love.graphics.draw(combatBackground, 0, 0)

    drawButtons(self.buttons)
end

function CombatScene:update(dt)
    for i = 1, table.getn(self.buttons) do
        local button = self.buttons[i]
        if input.mouseOver(button.rect) then
            button.active = true
            if input.getLeftClick() then
                button.activate()
            end
        else
            button.active = false
        end
    end
end

function combatScene.newCombatScene()
    return CombatScene:new()
end

return combatScene
