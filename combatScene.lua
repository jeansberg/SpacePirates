local resources = require("resources")
local input = require("input")
local utility = require("utility")
local timer = require("timer")
local stateMachine = require("stateMachine")
local shipAI = require("shipAI")
local lootSystem = require("loot")
local particles = require("particles")

local combatBackground = resources.images.combatScene
local bossShip = resources.images.bossShip
local merchantShip = resources.images.merchantShip
local pirateShip = resources.images.pirateShip
local bossportrait = resources.images.bossPortrait
local merchantportrait = resources.images.merchantPortrait
local pirateportrait = resources.images.piratePortrait

local greenLaser = resources.images.greenLaser
local redLaser = resources.images.redLaser
local health = resources.images.health

local reload = resources.sounds.reload

--[[
    Combat scene module.
    Code for handling combat encounters.
]]
local pirate = require("pirate")

local combatScene = {}
combatScene.projectiles = {}
combatScene.explosions = {}

combatScene.buttons = {
    utility.UI.newButton(
        320,
        460,
        "Leave",
        false,
        true,
        function()
            combatScene.exitScene()
        end,
        "smallFont"
    ),
    utility.UI.newButton(
        320,
        460,
        "Fight",
        false,
        true,
        function()
            combatScene.fsm:setState(combatScene.playerTurn)
        end,
        "smallFont"
    ),
    utility.UI.newButton(
        320,
        515,
        "Flee",
        false,
        true,
        function()
            combatScene.player:takeDamage(10)
            print(combatScene.player.hp)
            if combatScene.player.hp < 1 then
                local explosion = particles.getBigExplosion()
                table.insert(combatScene.explosions, explosion)
                explosion:setPosition(325, 245)
                explosion:emit(200)
                combatScene.timeOutState.nextState = combatScene.newTurnState
                combatScene.fsm:setState(combatScene.timeOutState)
            else
                combatScene.exitScene("fledCombat")
            end
        end,
        "smallFont"
    ),
    utility.UI.newButton(
        320,
        460,
        "Standard",
        false,
        true,
        function()
            local hit =
                combatScene.player:attack(combatScene.enemy, "standard", combatScene.usingAmmo)
            table.insert(
                combatScene.projectiles,
                {xPos = 557, yPos = 244, direction = "right", image = greenLaser, hit = hit}
            )
            combatScene.timeOutState.nextState = combatScene.enemyTurn
            combatScene.fsm:setState(combatScene.timeOutState)
        end,
        "smallFont"
    ),
    utility.UI.newButton(
        320,
        515,
        "Blinding",
        false,
        false,
        function()
            local hit =
                combatScene.player:attack(combatScene.enemy, "debuff", combatScene.usingAmmo)
            table.insert(
                combatScene.projectiles,
                {xPos = 557, yPos = 244, direction = "right", image = greenLaser, hit = hit}
            )
            combatScene.timeOutState.nextState = combatScene.enemyTurn
            combatScene.fsm:setState(combatScene.timeOutState)
        end,
        "smallFont"
    ),
    utility.UI.newButton(
        320,
        625,
        "Critical",
        false,
        false,
        function()
            local hit = combatScene.player:attack(combatScene.enemy, "crit", combatScene.usingAmmo)
            table.insert(
                combatScene.projectiles,
                {xPos = 557, yPos = 244, direction = "right", image = greenLaser, hit = hit}
            )
            combatScene.timeOutState.nextState = combatScene.enemyTurn
            combatScene.fsm:setState(combatScene.timeOutState)
        end,
        "smallFont"
    ),
    utility.UI.newButton(
        320,
        680,
        "Armor Piercing",
        false,
        false,
        function()
            local hit =
                combatScene.player:attack(combatScene.enemy, "pierce", combatScene.usingAmmo)
            table.insert(
                combatScene.projectiles,
                {xPos = 557, yPos = 244, direction = "right", image = greenLaser, hit = hit}
            )
            combatScene.timeOutState.nextState = combatScene.enemyTurn
            combatScene.fsm:setState(combatScene.timeOutState)
        end,
        "smallFont"
    ),
    utility.UI.newButton(
        320,
        570,
        "Use Ammo",
        false,
        true,
        function()
            combatScene.usingAmmo = not combatScene.usingAmmo
        end,
        "smallFont",
        reload
    ),
    utility.UI.newButton(
        550,
        570,
        "Restart",
        false,
        true,
        function()
            combatScene.exitScene("restart")
        end,
        "smallFont"
    )
}

combatScene.fsm = stateMachine.newStateMachine()

combatScene.newTurnState = stateMachine.newState()
function combatScene.newTurnState:enter()
    print("New turn...\n")
    if combatScene.player.hp > 0 then
        combatScene.buttons[2].visible = true
        combatScene.buttons[3].visible = true
        combatScene.buttons[9].visible = false
    else
        combatScene.buttons[2].visible = false
        combatScene.buttons[3].visible = false
        combatScene.buttons[9].visible = true
    end
end

function combatScene.newTurnState:exit()
    combatScene.buttons[2].visible = false
    combatScene.buttons[3].visible = false
end

combatScene.playerTurn = stateMachine.newState()
function combatScene.playerTurn:enter()
    print("Player turn...\n")
    combatScene.buttons[8].enabled = combatScene.player.numAmmo > 0

    combatScene.buttons[4].visible = true
    combatScene.buttons[5].visible = true
    combatScene.buttons[6].visible = true
    combatScene.buttons[7].visible = true
    combatScene.buttons[8].visible = true
end

function combatScene.playerTurn:update(dt)
    combatScene.buttons[8].selected = combatScene.usingAmmo and combatScene.player.numAmmo > 0
end

function combatScene.playerTurn:exit()
    if combatScene.player.numAmmo < 1 then
        combatScene.usingAmmo = false
        combatScene.buttons[8].enabled = false
    end

    if combatScene.enemy.hp < 1 then
        local explosion = particles.getBigExplosion()
        local explosion2 = particles.getBigExplosion()
        local explosion3 = particles.getBigExplosion()
        table.insert(combatScene.explosions, explosion)
        table.insert(combatScene.explosions, explosion2)
        table.insert(combatScene.explosions, explosion3)
        explosion:setPosition(955, 225)
        explosion:emit(1000)
        explosion2:setPosition(1076, 111)
        explosion2:emit(1000)
        explosion3:setPosition(960, 398)
        explosion3:emit(1000)
    end

    combatScene.buttons[4].visible = false
    combatScene.buttons[5].visible = false
    combatScene.buttons[6].visible = false
    combatScene.buttons[7].visible = false
    combatScene.buttons[8].visible = false
end

combatScene.enemyTurn = stateMachine.newState()
function combatScene.enemyTurn:enter()
    if combatScene.enemy.hp < 1 then
        combatScene.timeOutState.nextState = combatScene.enemyDeath
        combatScene.fsm:setState(combatScene.timeOutState)
    elseif combatScene.enemy.shipType == "pirate" and combatScene.enemy.hp < 10 then
        combatScene.timeOutState.nextState = combatScene.enemySurrender
        combatScene.fsm:setState(combatScene.timeOutState)
    else
        local hit = shipAI.takeAction(combatScene.enemy, combatScene.player)
        table.insert(
            combatScene.projectiles,
            {xPos = 722, yPos = 244, direction = "left", image = redLaser, hit = hit}
        )
        if combatScene.enemy.shipType == "keyStarPirate" or combatScene.enemy.shipType == "boss" then
            combatScene.timeOutState.nextState = combatScene.playerTurn
        else
            combatScene.timeOutState.nextState = combatScene.newTurnState
        end
        combatScene.fsm:setState(combatScene.timeOutState)
    end
end

function combatScene.enemyTurn:exit()
    if combatScene.player.hp < 1 then
        local explosion = particles.getBigExplosion()
        table.insert(combatScene.explosions, explosion)
        explosion:setPosition(325, 245)
        explosion:emit(200)
    end
end

local function drawLoot(loot)
    local lootIndex = 0
    resources.printWithFont(
        "smallFont",
        function()
            love.graphics.print("You receive:", 660, 500)
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
                    660,
                    500 + i * 20
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
            love.graphics.printf("Your enemy has surrendered!", 660, 460, 300)
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
            love.graphics.printf("Your enemy has been destroyed!", 660, 460, 300)
        end
    )

    drawLoot(combatScene.loot)
end

combatScene.timeOutState = stateMachine.newState()
combatScene.timeOutState.timer = timer.newTimer(1)

function combatScene.timeOutState:update(dt)
    if combatScene.enemy.hp < 1 then
        local xPos = math.random(830, 1145)
        local yPos = math.random(76, 392)
        if table.getn(combatScene.explosions) < 2 then
            local explosion = particles.getBigExplosion()
            table.insert(combatScene.explosions, explosion)
            explosion:setPosition(xPos, yPos)
            explosion:emit(100)
        end
    end

    if combatScene.player.hp < 1 then
        local xPos = math.random(196, 476)
        local yPos = math.random(160, 314)
        if table.getn(combatScene.explosions) < 2 then
            local explosion = particles.getBigExplosion()
            table.insert(combatScene.explosions, explosion)
            explosion:setPosition(xPos, yPos)
            explosion:emit(100)
        end
    end

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

function CombatScene:new(player, enemy)
    local o = {}
    combatScene.player = player
    combatScene.enemy = enemy
    enableWeapons(player)
    setmetatable(o, self)
    self.__index = self
    return o
end

local function asPercent(number)
    return tostring((number * 100)) .. "%"
end

local function drawHealthBars(player, enemy)
    love.graphics.draw(health, 432, 8, 0, player.hp / 250, 1)
    love.graphics.draw(health, 648, 8, 0, enemy.hp / enemy.maxHp, 1)
end

local function drawStats(player, enemy)
    local text = ""
    local offset = 0
    local drawFunction =
        function()
        resources.drawWithColor(
            0,
            0,
            0,
            255,
            function()
                love.graphics.print(text, 414 + offset, 400)
            end
        )
    end

    text = player.armor
    offset = 10
    resources.printWithFont("tinyFont", drawFunction)
    offset = offset + 50
    text = asPercent(player.dodge)
    resources.printWithFont("tinyFont", drawFunction)
    offset = offset + 65
    text = asPercent(player.crit)
    resources.printWithFont("tinyFont", drawFunction)
    offset = offset + 60
    text = player.numAmmo
    resources.printWithFont("tinyFont", drawFunction)
    text = enemy.armor
    offset = offset + 70
    resources.printWithFont("tinyFont", drawFunction)
    offset = offset + 50
    text = asPercent(enemy.dodge)
    resources.printWithFont("tinyFont", drawFunction)
    offset = offset + 65
    text = asPercent(enemy.crit)
    resources.printWithFont("tinyFont", drawFunction)
    offset = offset + 60
    text = enemy.numAmmo
    resources.printWithFont("tinyFont", drawFunction)

    offset = 0
    drawFunction =
        function()
        resources.drawWithColor(
            0,
            0,
            0,
            255,
            function()
                love.graphics.print(text, 440 + offset, 15)
            end
        )
    end

    text = combatScene.player.hp
    resources.printWithFont("smallFont", drawFunction)
    offset = offset + 215
    text = combatScene.enemy.hp
    resources.printWithFont("smallFont", drawFunction)
end

local function drawProjectile()
    for i = 1, table.getn(combatScene.projectiles) do
        local projectile = combatScene.projectiles[i]
        love.graphics.draw(projectile.image, projectile.xPos, projectile.yPos)
    end
end

local function updateProjectile(dt)
    for i = 1, table.getn(combatScene.projectiles) do
        local projectile = combatScene.projectiles[i]
        if projectile.direction == "left" then
            projectile.xPos = projectile.xPos - dt * 2000
            if projectile.hit and projectile.xPos < 560 then
                table.remove(combatScene.projectiles, i)
                local explosion = particles.getExplosion()
                table.insert(combatScene.explosions, explosion)
                explosion:setPosition(projectile.xPos, projectile.yPos)
                explosion:emit(100)
            end
        else
            projectile.xPos = projectile.xPos + dt * 2000
            if projectile.hit and projectile.xPos > 722 then
                table.remove(combatScene.projectiles, i)
                local explosion = particles.getExplosion()
                table.insert(combatScene.explosions, explosion)
                explosion:setPosition(projectile.xPos, projectile.yPos)
                explosion:emit(100)
            end
        end
    end
end

function CombatScene:draw()
    love.graphics.draw(combatBackground, 0, 0)

    drawProjectile()
    for _, explosion in ipairs(combatScene.explosions) do
        love.graphics.draw(explosion, 0, 0)
    end
    drawHealthBars(combatScene.player, combatScene.enemy)
    drawStats(combatScene.player, combatScene.enemy)

    utility.UI.drawButtons(self.buttons)
    combatScene.fsm.state:draw()

    local portraitImage = {}
    local shipImage = {}
    if combatScene.enemy.shipType == "merchantShip" then
        portraitImage = merchantportrait
        shipImage = merchantShip
    elseif combatScene.enemy.shipType == "keyStarPirate" or combatScene.enemy.shipType == "boss" then
        portraitImage = bossportrait
        shipImage = bossShip
    else
        portraitImage = pirateportrait
        shipImage = pirateShip
    end

    love.graphics.draw(portraitImage, 1015, 440)
    love.graphics.draw(shipImage, 755, -10)
end

function CombatScene:update(dt)
    combatScene.fsm.state:update(dt)

    updateProjectile(dt)
    particles.updateExplosions(dt, combatScene.explosions)

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

function combatScene.newCombatScene(player, enemy)
    local scene = CombatScene:new(player, enemy)
    combatScene.fsm:setState(combatScene.newTurnState)
    return scene
end

return combatScene
