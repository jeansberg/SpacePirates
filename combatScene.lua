local resources = require("resources")
local input = require("input")
local utility = require("utility")

local combatBackground = resources.images.combatScene

--[[
    Combat scene module.
    Code for handling combat encounters.
]]
local pirate = require("pirate")

local combatScene = {}
function combatScene.init(exitScene)
    combatScene.exitScene = exitScene
end

--[[
    Combat scene class.
]]
local CombatScene = {}
CombatScene.buttons = {
    utility.newButton(
        40,
        700,
        "Back",
        true,
        function()
            combatScene.exitScene()
        end,
        "smallFont"
    )
}

function CombatScene:new(player)
    local o = {}
    o.player = player
    o.enemy = pirate.newPirate()
    setmetatable(o, self)
    self.__index = self
    return o
end

local function asPercent(number)
    return tostring((number * 100)) .. "%"
end

local function drawPlayerStats(player)
    local text = ""
    local offset = 0
    local drawFunction = function()
        love.graphics.print(text, 20, 480 + offset)
    end
    text = "Health " .. player.hp
    resources.printWithFont("smallFont", drawFunction)
    offset = offset + 20
    text = "Armor  " .. player.armor
    resources.printWithFont("smallFont", drawFunction)
    offset = offset + 20
    text = "Dodge  " .. asPercent(player.dodge)
    resources.printWithFont("smallFont", drawFunction)
    offset = offset + 20
    text = "Crit   " .. asPercent(player.dodge)
    resources.printWithFont("smallFont", drawFunction)
    offset = offset + 20
    text = "Ammo   " .. player.numAmmo
    resources.printWithFont("smallFont", drawFunction)
end

local function drawButtons(buttons)
    local button = {}
    local printFunction = function()
        love.graphics.print(button.text, button.xPos, button.yPos)
    end

    for i = 1, table.getn(buttons) do
        button = buttons[i]
        print("button " .. buttons[i].text)
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

    drawPlayerStats(self.player)
    drawButtons(self.buttons)
end

function CombatScene:update(dt)
    for i = 1, table.getn(self.buttons) do
        local button = self.buttons[i]
        if input.mouseOver(button:getRect()) then
            button.active = true
            if input.getLeftClick() then
                button.execute()
            end
        else
            button.active = false
        end
    end
end

function combatScene.newCombatScene(player)
    return CombatScene:new(player)
end

return combatScene
