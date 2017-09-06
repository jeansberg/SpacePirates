local resources = require("resources")
local input = require("input")
local utility = require("utility")
local timer = require("timer")
local stateMachine = require("stateMachine")
local shipAI = require("shipAI")
local lootSystem = require("loot")

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
        "Exit",
        false,
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
        true,
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
        true,
        function()
            combatScene.player:takeDamage(10)
            if combatScene.player.hp < 1 then
                combatScene.exitScene("diedFleeing")
            else
                combatScene.exitScene("fledCombat")
            end
        end,
        "smallFont"
    ),
    utility.newButton(
        450,
        500,
        "Standard",
        false,
        true,
        function()
            combatScene.player:attack(combatScene.enemy, "standard", combatScene.usingAmmo)
            combatScene.timeOutState.nextState = combatScene.enemyTurn
            combatScene.fsm:setState(combatScene.timeOutState)
        end,
        "smallFont"
    ),
    utility.newButton(
        650,
        500,
        "Blinding",
        false,
        false,
        function()
            combatScene.player:attack(combatScene.enemy, "debuff", combatScene.usingAmmo)
            combatScene.timeOutState.nextState = combatScene.enemyTurn
            combatScene.fsm:setState(combatScene.timeOutState)
        end,
        "smallFont"
    ),
    utility.newButton(
        450,
        600,
        "Critical",
        false,
        false,
        function()
            combatScene.player:attack(combatScene.enemy, "crit", combatScene.usingAmmo)
            combatScene.timeOutState.nextState = combatScene.enemyTurn
            combatScene.fsm:setState(combatScene.timeOutState)
        end,
        "smallFont"
    ),
    utility.newButton(
        650,
        600,
        "Armor Piercing",
        false,
        false,
        function()
            combatScene.player:attack(combatScene.enemy, "pierce", combatScene.usingAmmo)
            combatScene.timeOutState.nextState = combatScene.enemyTurn
            combatScene.fsm:setState(combatScene.timeOutState)
        end,
        "smallFont"
    )
}

combatScene.fsm = stateMachine.newStateMachine()

combatScene.newTurnState = stateMachine.newState()
function combatScene.newTurnState:enter()
    print("New turn...\n")
    combatScene.buttons[2].visible = true
    combatScene.buttons[3].visible = true
end

function combatScene.newTurnState:exit()
    combatScene.buttons[2].visible = false
    combatScene.buttons[3].visible = false
end

combatScene.playerTurn = stateMachine.newState()
function combatScene.playerTurn:enter()
    print("Player turn...\n")
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

combatScene.enemyTurn = stateMachine.newState()
function combatScene.enemyTurn:enter()
    if combatScene.enemy.shipType == "pirate" and combatScene.enemy.hp < 1 then
        combatScene.timeOutState.nextState = combatScene.enemyDeath
        combatScene.fsm:setState(combatScene.timeOutState)
    elseif combatScene.enemy.shipType == "pirate" and combatScene.enemy.hp < 10 then
        combatScene.timeOutState.nextState = combatScene.enemySurrender
        combatScene.fsm:setState(combatScene.timeOutState)
    else
        shipAI.takeAction(combatScene.enemy, combatScene.player)

        combatScene.timeOutState.nextState = combatScene.newTurnState
        combatScene.fsm:setState(combatScene.timeOutState)
    end
end

function combatScene.enemyTurn:update(dt)
end

local function drawLoot(loot)
    local lootIndex = 0
    resources.printWithFont(
        "smallFont",
        function()
            love.graphics.print("You receive:", 400, 520)
        end
    )

    for i = 1, table.getn(loot) do
        lootIndex = i
        local lootItem = loot[i]
        resources.printWithFont(
            "smallFont",
            function()
                love.graphics.print(
                    tostring(lootItem.amount) .. " " .. lootItem.text,
                    500,
                    520 + i * 20
                )
            end
        )
    end
end

combatScene.enemySurrender = stateMachine.newState()
function combatScene.enemySurrender:enter()
    print("Enemy surrender...\n")
    combatScene.buttons[1].visible = true
    combatScene.loot = lootSystem.getLoot(combatScene.player, combatScene.enemy, "surrender")
end

function combatScene.enemySurrender:draw()
    resources.printWithFont(
        "smallFont",
        function()
            love.graphics.print("Your enemy has surrendered!", 400, 500)
        end
    )

    drawLoot(combatScene.loot)
end

combatScene.enemyDeath = stateMachine.newState()
function combatScene.enemyDeath:enter()
    print("Enemy death...\n")
    combatScene.buttons[1].visible = true
    combatScene.loot = lootSystem.getLoot(combatScene.player, combatScene.enemy, "death")
end

function combatScene.enemyDeath:draw()
    resources.printWithFont(
        "smallFont",
        function()
            love.graphics.print("Your enemy has been destroyed!", 400, 500)
        end
    )

    drawLoot(combatScene.loot)
end

combatScene.timeOutState = stateMachine.newState()
combatScene.timeOutState.timer = timer.newTimer(2)

function combatScene.timeOutState:update(dt)
    if self.timer:update(dt) then
        combatScene.fsm:setState(self.nextState)
    end
end

function combatScene.timeOutState:enter()
    print("Timeout...\n")
    self.timer:restart()
end

function combatScene.init(exitScene)
    combatScene.exitScene = exitScene
end

local function enableWeapons(player)
    combatScene.buttons[5].enabled = player.weapons["debuff"]
    combatScene.buttons[6].enabled = player.weapons["crit"]
    combatScene.buttons[7].enabled = player.weapons["pierce"]
end

--[[
    Combat scene class.
]]
local CombatScene = {buttons = combatScene.buttons}

function CombatScene:new(player)
    local o = {}
    combatScene.player = player
    combatScene.enemy = pirate.newPirate()
    enableWeapons(player)
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
    text = "Crit   " .. asPercent(player.crit)
    resources.printWithFont("smallFont", drawFunction)
    offset = offset + 20
    text = "Ammo   " .. player.numAmmo
    resources.printWithFont("smallFont", drawFunction)
    offset = offset + 20
    text = "Enemy hp " .. combatScene.enemy.hp
    resources.printWithFont("smallFont", drawFunction)
end

function CombatScene:draw()
    love.graphics.draw(combatBackground, 0, 0)

    drawPlayerStats(combatScene.player)
    utility.drawButtons(self.buttons)
    combatScene.fsm.state:draw()
end

function CombatScene:update(dt)
    combatScene.fsm.state:update(dt)

    for i = 1, table.getn(self.buttons) do
        local button = self.buttons[i]
        if button.visible and button.enabled then
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
