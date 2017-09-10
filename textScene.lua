local resources = require("resources")
local utility = require("utility")
local stateMachine = require("stateMachine")

local purchaseSound = resources.sounds.purchase
local textSceneImage = resources.images.textScene

local textScene = {}
function textScene.init(exitScene, enterCombat)
    textScene.exitScene = exitScene
    textScene.enterCombat = enterCombat
end

local function getUniqueUpgrade()
    local possibleUpgrades = {}
    if textScene.player.dodge < 1 then
        table.insert(possibleUpgrades, {"dodge", "Dodge upgrade"})
    end
    if textScene.player.crit < 1 then
        table.insert(possibleUpgrades, {"crit", "Crit upgrade"})
    end
    table.insert(possibleUpgrades, {"armor", "Armor upgrade"})

    local roll = math.random(1, table.getn(possibleUpgrades))
    return possibleUpgrades[roll]
end

local function drawDescription()
    local text
    local drawFunction = function()
        love.graphics.printf(text, 660, 460, 500)
    end
    if textScene.type == "trade" then
        text =
            "A civilian ship requests to trade a " .. textScene.upgrade[2] .. " for 3 special ammo."
    elseif textScene.type == "wreckage" then
        text =
            "There appears to be the wreckage of a ship nearby. Do you want to try and scrap it for parts?"
    elseif textScene.type == "asteroids" then
        text =
            "There is an incoming asteroid field. Do you want to risk flying through it, or wait for it to pass?"
    elseif textScene.type == "help" then
        text = "A nearby civilian ship is being raided by pirates."
    end

    resources.printWithFont("smallFont", drawFunction)
end

textScene.initialState = stateMachine.newState()
function textScene.initialState:draw()
    drawDescription()
    utility.UI.drawButtons(textScene.buttons)
end

function textScene.initialState:enter()
    textScene.buttons[1].visible = false
    textScene.buttons[2].visible = false
    textScene.buttons[3].visible = false
    textScene.buttons[4].visible = false
    textScene.buttons[5].visible = false
    textScene.buttons[6].visible = false
    textScene.buttons[7].visible = false
    textScene.buttons[8].visible = false
    textScene.buttons[9].visible = false

    if textScene.type == "trade" then
        if textScene.player.numAmmo < 3 then
            textScene.buttons[1].enabled = false
        else
            textScene.buttons[1].enabled = true
        end
        textScene.buttons[1].visible = true
        textScene.buttons[2].visible = true

        textScene.upgrade = {}
        textScene.upgrade = getUniqueUpgrade()
    elseif textScene.type == "wreckage" then
        textScene.buttons[3].visible = true
        textScene.buttons[4].visible = true
    elseif textScene.type == "asteroids" then
        textScene.buttons[5].visible = true
        textScene.buttons[6].visible = true
    elseif textScene.type == "help" then
        textScene.buttons[7].visible = true
    end
end

function textScene.initialState:exit()
    textScene.buttons[1].visible = false
    textScene.buttons[2].visible = false
    textScene.buttons[3].visible = false
    textScene.buttons[4].visible = false
    textScene.buttons[5].visible = false
    textScene.buttons[6].visible = false
    textScene.buttons[7].visible = false
    textScene.buttons[8].visible = false
    textScene.buttons[9].visible = false
end

function textScene.initialState:update(dt)
    utility.UI.updateButtons(textScene.buttons)
end

local function drawConsequences()
    local text
    local drawFunction = function()
        love.graphics.printf(text, 660, 460, 500)
    end
    if textScene.type == "trade" then
        text = "You complete the trade."
    elseif textScene.type == "wreckage" then
        resources.printWithFont(
            "smallFont",
            function()
                love.graphics.print("You receive:", 660, 600)
            end
        )

        resources.printWithFont(
            "smallFont",
            function()
                love.graphics.print(tostring(textScene.money) .. " money", 660, 620)
            end
        )
        resources.printWithFont(
            "smallFont",
            function()
                love.graphics.print(tostring(textScene.ammo) .. " ammo", 660, 640)
            end
        )
    elseif textScene.type == "asteroids" then
        if textScene.player.hp > 1 then
            text = "An asteroid hits your ship for 20 damage!"
        else
            text = "The asteroids tear your ship apart!"
        end
    end

    resources.printWithFont("smallFont", drawFunction)
end

textScene.finalState = stateMachine.newState()
function textScene.finalState:draw()
    drawConsequences()
    utility.UI.drawButtons(textScene.buttons)
end

function textScene.finalState:update(dt)
    if textScene.player.hp < 1 then
        textScene.buttons[9].visible = true
    else
        textScene.buttons[8].visible = true
    end

    utility.UI.updateButtons(textScene.buttons)
end

textScene.buttons = {
    utility.UI.newButton(
        320,
        460,
        "Trade",
        false,
        true,
        function()
            if textScene.upgrade[1] == "dodge" then
                textScene.player.dodge = math.min(textScene.player.dodge + 0.1, 1)
            elseif textScene.upgrade[1] == "crit" then
                textScene.player.crit = math.min(textScene.player.crit + 0.1, 1)
            elseif textScene.upgrade[1] == "armor" then
                textScene.player.armor = textScene.player.armor + 1
            end
            textScene.player.numAmmo = textScene.player.numAmmo - 3
            resources.playSound(purchaseSound)
            textScene.exitScene()
        end,
        "smallFont"
    ),
    utility.UI.newButton(
        320,
        515,
        "Deny",
        false,
        true,
        function()
            textScene.exitScene()
        end,
        "smallFont"
    ),
    utility.UI.newButton(
        320,
        460,
        "Scrap",
        false,
        true,
        function()
            if math.random(1, 100) > 35 then
                textScene.enterCombat("pirate", true)
            else
                textScene.money = 0
                textScene.ammo = 0
                if math.random(0, 1) == 1 then
                    textScene.money = 10
                else
                    textScene.money = 20
                end
                if math.random(0, 1) == 1 then
                    textScene.ammo = 1
                else
                    textScene.ammo = 2
                end
                textScene.player.money = textScene.player.money + textScene.money
                textScene.player.numAmmo = textScene.player.numAmmo + textScene.ammo
                textScene.fsm:setState(textScene.finalState)
            end
        end,
        "smallFont"
    ),
    utility.UI.newButton(
        320,
        515,
        "Ignore",
        false,
        true,
        function()
            textScene.exitScene()
        end,
        "smallFont"
    ),
    utility.UI.newButton(
        320,
        460,
        "Traverse",
        false,
        true,
        function()
            if math.random(1, 10) > 2 then
                textScene.player:takeDamage(20)
                textScene.fsm:setState(textScene.finalState)
            else
                textScene.exitScene()
            end
        end,
        "smallFont"
    ),
    utility.UI.newButton(
        320,
        515,
        "Wait",
        false,
        true,
        function()
            if math.random(1, 10) > 6 then
                textScene.enterCombat("pirate", true)
            else
                textScene.exitScene()
            end
        end,
        "smallFont"
    ),
    utility.UI.newButton(
        320,
        460,
        "Help",
        false,
        true,
        function()
            print("Entering combat with pirate")
            textScene.enterCombat("pirate", true)
        end,
        "smallFont"
    ),
    utility.UI.newButton(
        320,
        460,
        "Exit",
        true,
        true,
        function()
            textScene.exitScene()
        end,
        "smallFont"
    ),
    utility.UI.newButton(
        320,
        460,
        "Restart",
        false,
        true,
        function()
            textScene.exitScene("restart")
        end,
        "smallFont"
    )
}

textScene.fsm = stateMachine.newStateMachine()

local function randomizeType(level)
    local roll
    if level == "normal" then
        roll = math.random(1, 4)
    else
        roll = math.random(2, 4)
    end

    if roll == 1 then
        return "trade"
    elseif roll == 2 then
        return "wreckage"
    elseif roll == 3 then
        return "asteroids"
    else
        return "help"
    end
end

local Encounter = {}

function Encounter:new(level, player)
    local o = {type = randomizeType(level), level = level}
    textScene.type = o.type
    print("textScene.type " .. textScene.type)
    textScene.player = player
    setmetatable(o, self)
    self.__index = self
    return o
end

function Encounter:draw()
    love.graphics.draw(textSceneImage, 0, 0)
    textScene.fsm.state:draw()
end

function Encounter:update(dt)
    textScene.fsm.state:update(dt)
end

function textScene.newEncounter(level, player)
    local encounter = Encounter:new(level, player)
    textScene.fsm:setState(textScene.initialState)
    return encounter
end

return textScene
