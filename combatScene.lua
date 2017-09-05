local resources = require("resources")
local input = require("input")
local utility = require("utility")
local stateMachine = require("stateMachine")

local combatBackground = resources.images.combatScene

--[[
    Combat scene module.
    Code for handling combat encounters.
]]
local pirate = require("pirate")

local combatScene = {}

combatScene.buttons = {
    utility.newButton(
        40,
        700,
        "Back",
        true,
        function()
            combatScene.exitScene()
        end,
        "smallFont"
    ),
    utility.newButton(
        450,
        500,
        "Fight",
        false,
        function()
            combatScene.fsm:setState(combatScene.playerTurn)
        end,
        "smallFont"
    ),
    utility.newButton(
        650,
        500,
        "Flee",
        false,
        function()
            combatScene.player:takeDamage(10)
            combatScene.exitScene()
        end,
        "smallFont"
    ),
    utility.newButton(
        450,
        500,
        "Standard",
        false,
        function()
            combatScene.exitScene()
        end,
        "smallFont"
    ),
    utility.newButton(
        650,
        500,
        "Blinding",
        false,
        function()
            combatScene.exitScene()
        end,
        "smallFont"
    ),
    utility.newButton(
        450,
        600,
        "Critical",
        false,
        function()
            combatScene.exitScene()
        end,
        "smallFont"
    ),
    utility.newButton(
        650,
        600,
        "Armor Piercing",
        false,
        function()
            combatScene.exitScene()
        end,
        "smallFont"
    )
}

combatScene.fsm = stateMachine.newStateMachine()

combatScene.newTurnState = stateMachine.newState()
function combatScene.newTurnState:enter()
    combatScene.buttons[2].visible = true
    combatScene.buttons[3].visible = true
end

function combatScene.newTurnState:exit()
    combatScene.buttons[2].visible = false
    combatScene.buttons[3].visible = false
end

combatScene.playerTurn = stateMachine.newState()
function combatScene.playerTurn:enter()
    combatScene.buttons[4].visible = true
    combatScene.buttons[5].visible = true
    combatScene.buttons[6].visible = true
    combatScene.buttons[7].visible = true
end

function combatScene.playerTurn:exit()
    combatScene.buttons[4].visible = false
    combatScene.buttons[5].visible = false
    combatScene.buttons[6].visible = false
    combatScene.buttons[7].visible = false
end

function combatScene.init(exitScene)
    combatScene.exitScene = exitScene
end

--[[
    Combat scene class.
]]
local CombatScene = {buttons = combatScene.buttons}

function CombatScene:new(player)
    local o = {}
    combatScene.player = player
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

function CombatScene:draw()
    love.graphics.draw(combatBackground, 0, 0)

    drawPlayerStats(combatScene.player)
    utility.drawButtons(self.buttons)
end

function CombatScene:update(dt)
    for i = 1, table.getn(self.buttons) do
        local button = self.buttons[i]
        if button.visible then
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
end

function combatScene.newCombatScene(player)
    combatScene.fsm:setState(combatScene.newTurnState)
    return CombatScene:new(player)
end

return combatScene
