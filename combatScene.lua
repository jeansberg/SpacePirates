local resources = require("resources")
local input = require("input")
local utility = require("utility")
local timer = require("timer")
local stateMachine = require("stateMachine")
local shipAI = require("shipAI")
local lootSystem = require("loot")
local particles = require("particles")

local combatBackground = resources.images.combatScene
local cityBackground = resources.images.cityScene
local bossShip = resources.images.bossShip
local merchantShip = resources.images.merchantShip
local pirateShip = resources.images.pirateShip
local bossportrait = resources.images.bossPortrait
local merchantportrait = resources.images.merchantPortrait
local pirateportrait = resources.images.piratePortrait

local repairIcon = resources.images.repairIcon
local ammoIcon = resources.images.ammoIcon
local dodgeIcon = resources.images.dodgeIcon
local critIcon = resources.images.critIcon
local armorIcon = resources.images.armorIcon
local critCannonIcon = resources.images.critCannonIcon
local debuffCannonIcon = resources.images.debuffCannonIcon
local pierceCannonIcon = resources.images.pierceCannonIcon

local greenLaser = resources.images.greenLaser
local redLaser = resources.images.redLaser
local health = resources.images.health

local reload = resources.sounds.reload
local repair = resources.sounds.repair
local purchaseSound = resources.sounds.purchase

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
            if combatScene.enemy.shipType == "keyStarPirate" then
                combatScene.exitScene("foundBoss")
            else
                combatScene.exitScene()
            end
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
                combatScene.timeOutState.nextState = combatScene.playerDeath
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
        320,
        460,
        "Restart",
        false,
        true,
        function()
            combatScene.exitScene("restart")
        end,
        "smallFont"
    ),
    utility.UI.newButton(
        320,
        515,
        "Trade",
        false,
        true,
        function()
            combatScene.fsm:setState(combatScene.tradingState)
        end,
        "smallFont"
    ),
    utility.UI.newButton(
        40,
        700,
        "Exit",
        true,
        true,
        function()
            combatScene.exitScene()
        end,
        "smallFont"
    )
}

combatScene.fsm = stateMachine.newStateMachine()

combatScene.initialState = stateMachine.newState()

local function getUniqueGun(weapons)
    if math.random(0, 1) == 0 then
        return
    end

    local specialWeapons = {}
    table.insert(specialWeapons, "debuff")
    table.insert(specialWeapons, "crit")
    table.insert(specialWeapons, "pierce")

    local roll = math.random(1, table.getn(specialWeapons))
    local receivedWeapon = specialWeapons[roll]
    weapons[receivedWeapon] = true
end

local function getUniqueUpgrade(upgrades)
    local possibleUpgrades = {}
    table.insert(possibleUpgrades, "dodge")
    table.insert(possibleUpgrades, "crit")
    table.insert(possibleUpgrades, "armor")

    local roll = math.random(1, table.getn(possibleUpgrades))
    local receivedUpgrade = possibleUpgrades[roll]
    upgrades[receivedUpgrade] = true
end

local function generateInventory()
    combatScene.weapons = {}
    combatScene.upgrades = {}
    getUniqueGun(combatScene.weapons)
    getUniqueUpgrade(combatScene.upgrades)
end

local function clearInventory()
    combatScene.weapons = {}
    combatScene.upgrades = {}
end

function combatScene.initialState:enter()
    print("enter initial state\n")
    combatScene.buttons[11].visible = false
    combatScene.buttons[1].visible = false
    combatScene.newTurnState.firstTurn = true
    combatScene.fsm:setState(combatScene.newTurnState)
end

function combatScene.initialState:draw()
end

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
    combatScene.newTurnState.firstTurn = false
end

function combatScene.newTurnState.draw()
    if combatScene.newTurnState.firstTurn then
        local introText
        if combatScene.enemy.shipType == "keyStarPirate" then
            introText =
                "You have discovered the key to your final destination, but it appears to be guarded by a powerful pirate. Are you ready for this fight?"
        elseif combatScene.enemy.shipType == "boss" then
            introText =
                "You have arrived at your final destination. Are you ready to fight the Pirate King?"
        elseif combatScene.enemy.shipType == "merchantShip" then
            introText = "You have encountered a merchant ship."
            combatScene.buttons[3].visible = false
            combatScene.buttons[10].visible = true
        else
            introText = "You have encountered a pirate ship."
        end

        local printFunction = function()
            love.graphics.printf(introText, 660, 460, 340)
        end

        resources.printWithFont("smallFont", printFunction)
    end
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

    combatScene.buttons[10].visible = false
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
        if combatScene.player.hp < 1 then
            combatScene.timeOutState.nextState = combatScene.playerDeath
        elseif combatScene.enemy.shipType == "keyStarPirate" or combatScene.enemy.shipType == "boss" then
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
    if table.getn(loot) < 1 then
        return
    end
    local lootIndex = 0
    resources.printWithFont(
        "smallFont",
        function()
            love.graphics.print("You receive:", 660, 600)
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
                    600 + i * 20
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

    if combatScene.enemy.shipType == "boss" then
        combatScene.buttons[9].visible = true
    else
        combatScene.buttons[1].visible = true
    end
    combatScene.loot = lootSystem.getLoot(combatScene.player, combatScene.enemy, "death")
end

function combatScene.enemyDeath:draw()
    local endText
    if combatScene.enemy.shipType == "keyStarPirate" then
        endText =
            "You have defeated the guardian of the key! Now you can access your final destination."
    elseif combatScene.enemy.shipType == "boss" then
        endText =
            "You have defeated the Pirate King and assumed his role as King of the Stars! Game over."
    else
        endText = "Your enemy has been destroyed!"
    end

    resources.printWithFont(
        "smallFont",
        function()
            love.graphics.printf(endText, 660, 460, 320)
        end
    )

    drawLoot(combatScene.loot)
end

combatScene.playerDeath = stateMachine.newState()
function combatScene.playerDeath:enter()
    print("Player death...\n")

    combatScene.buttons[9].visible = true
end

function combatScene.playerDeath.draw()
    resources.printWithFont(
        "smallFont",
        function()
            love.graphics.printf("You have been destroyed!", 660, 460, 320)
        end
    )
end

combatScene.tradingState = stateMachine.newState()

local iconStart = 44
local iconOffset = 150

local function showAvailable(weapons, upgrades)
    if upgrades["dodge"] then
        combatScene.icons[3].visible = true
    end
    if upgrades["crit"] then
        combatScene.icons[4].visible = true
    end
    if upgrades["armor"] then
        combatScene.icons[5].visible = true
    end

    if weapons["crit"] then
        combatScene.icons[6].visible = true
    end
    if weapons["debuff"] then
        combatScene.icons[7].visible = true
    end
    if weapons["pierce"] then
        combatScene.icons[8].visible = true
    end
end

local function updateAvailable(node)
    if not node.upgrades["dodge"] then
        combatScene.icons[3].visible = false
    end
    if not node.upgrades["crit"] then
        combatScene.icons[4].visible = false
    end
    if not node.upgrades["armor"] then
        combatScene.icons[5].visible = false
    end

    if not node.weapons["crit"] then
        combatScene.icons[6].visible = false
    end
    if not node.weapons["debuff"] then
        combatScene.icons[7].visible = false
    end
    if not node.weapons["pierce"] then
        combatScene.icons[8].visible = false
    end
end

local function updateAffordable()
    if combatScene.player.money < 50 or combatScene.player.weapons["crit"] then
        combatScene.icons[6].enabled = false
    end
    if combatScene.player.money < 50 or combatScene.player.weapons["debuff"] then
        combatScene.icons[7].enabled = false
    end
    if combatScene.player.money < 50 or combatScene.player.weapons["pierce"] then
        combatScene.icons[8].enabled = false
    end

    if combatScene.player.money < 20 or combatScene.player.dodge > 0.9 then
        combatScene.icons[3].enabled = false
    end
    if combatScene.player.money < 20 or combatScene.player.crit > 0.9 then
        combatScene.icons[4].enabled = false
    end
    if combatScene.player.money < 20 or combatScene.player.armor > 0.9 then
        combatScene.icons[5].enabled = false
    end

    if combatScene.player.money < 10 or combatScene.player.hp > 249 then
        combatScene.icons[1].enabled = false
    end

    if combatScene.player.money < 10 then
        combatScene.icons[2].enabled = false
    end
end

local function purchase(node, item)
    local player = combatScene.player
    if item == "repair" then
        player.money = player.money - 10
        player.hp = math.min(player.hp + 20, 250)
    elseif item == "ammo" then
        player.money = player.money - 10
        player.numAmmo = player.numAmmo + 1
    elseif item == "dodge" then
        player.money = player.money - 20
        player.dodge = math.min(player.dodge + 0.1, 1)
        node.upgrades["dodge"] = false
    elseif item == "crit" then
        player.money = player.money - 20
        player.crit = math.min(player.crit + 0.1, 1)
        node.upgrades["crit"] = false
    elseif item == "armor" then
        player.money = player.money - 20
        player.armor = player.armor + 1
        node.upgrades["armor"] = false
    elseif item == "debuffCannon" then
        player.money = player.money - 50
        player.weapons["debuff"] = true
        node.weapons["debuff"] = false
    elseif item == "critCannon" then
        player.money = player.money - 50
        player.weapons["crit"] = true
        node.weapons["crit"] = false
    elseif item == "pierceCannon" then
        player.money = player.money - 50
        player.weapons["pierce"] = true
        node.weapons["pierce"] = false
    end

    updateAffordable()
    updateAvailable(node)
end

function combatScene.initIcons()
    combatScene.icons = {
        utility.UI.newIcon(
            iconStart,
            440,
            repairIcon,
            true,
            true,
            function()
                purchase(combatScene, "repair")
            end,
            "Restore 20 HP to your ship.\nCost: 10.",
            repair
        ),
        utility.UI.newIcon(
            iconStart + iconOffset * 1,
            440,
            ammoIcon,
            true,
            true,
            function()
                purchase(combatScene, "ammo")
            end,
            "Lets you perform an upgraded attack.\nCost: 10.",
            reload
        ),
        utility.UI.newIcon(
            iconStart + iconOffset * 2,
            440,
            dodgeIcon,
            false,
            true,
            function()
                purchase(combatScene, "dodge")
            end,
            "Increases your ship's dodge chance by 10%.\nCost: 30.",
            purchaseSound
        ),
        utility.UI.newIcon(
            iconStart + iconOffset * 3,
            440,
            critIcon,
            false,
            true,
            function()
                purchase(combatScene, "crit")
            end,
            "Increases your ship's critical hit chance by 10%.\nCost: 30.",
            purchaseSound
        ),
        utility.UI.newIcon(
            iconStart + iconOffset * 4,
            440,
            armorIcon,
            false,
            true,
            function()
                purchase(combatScene, "armor")
            end,
            "Adds 1 point of armor to your ship.\nCost: 30.",
            purchaseSound
        ),
        utility.UI.newIcon(
            iconStart + iconOffset * 5,
            440,
            critCannonIcon,
            false,
            true,
            function()
                purchase(combatScene, "critCannon")
            end,
            "Does 6 damage and has +20% chance to critically strike.\nCost: 50.",
            purchaseSound
        ),
        utility.UI.newIcon(
            iconStart + iconOffset * 6,
            440,
            debuffCannonIcon,
            false,
            true,
            function()
                purchase(combatScene, "debuffCannon")
            end,
            "Does 4 damage and increases the user's dodge chance by +10%.\nCost: 50.",
            purchaseSound
        ),
        utility.UI.newIcon(
            iconStart + iconOffset * 7,
            440,
            pierceCannonIcon,
            false,
            true,
            function()
                purchase(combatScene, "pierceCannon")
            end,
            "Does 8 damage and ignores enemy armor. Cannot critically strike.\nCost: 50.",
            purchaseSound
        )
    }
end

function combatScene.tradingState:enter()
    combatScene.buttons[10].visible = false
    combatScene.buttons[11].visible = true
    combatScene.initIcons()
    generateInventory()
    showAvailable(combatScene.weapons, combatScene.upgrades)
    updateAffordable()
end

function combatScene.tradingState:exit()
    clearInventory()
end

function combatScene.tradingState:update(dt)
    utility.UI.updateIcons(combatScene.icons)
end

local function drawDescription()
    local text
    local drawFunction = function()
        love.graphics.printf(text, 150, 100, 400)
    end

    for i = 1, table.getn(combatScene.icons) do
        local icon = combatScene.icons[i]
        if icon.active then
            text = icon.description
            resources.printWithFont("smallFont", drawFunction)
        end
    end
end

function combatScene.tradingState:draw()
    love.graphics.draw(cityBackground, 0, 0)

    utility.UI.drawIcons(combatScene.icons)
    resources.printWithFont(
        "tinyFont",
        function()
            love.graphics.print("Money:" .. combatScene.player.money, 150, 350)
        end
    )
    resources.printWithFont(
        "tinyFont",
        function()
            love.graphics.print("Hp:" .. combatScene.player.hp, 150, 330)
        end
    )
    resources.printWithFont(
        "tinyFont",
        function()
            love.graphics.print("Dodge:" .. combatScene.player.dodge, 350, 350)
        end
    )
    resources.printWithFont(
        "tinyFont",
        function()
            love.graphics.print("Crit:" .. combatScene.player.crit, 450, 350)
        end
    )
    resources.printWithFont(
        "tinyFont",
        function()
            love.graphics.print("Armor:" .. combatScene.player.armor, 550, 350)
        end
    )
    resources.printWithFont(
        "tinyFont",
        function()
            love.graphics.print("Ammo:" .. combatScene.player.numAmmo, 350, 330)
        end
    )

    drawDescription()
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

    drawHealthBars(combatScene.player, combatScene.enemy)
    drawStats(combatScene.player, combatScene.enemy)

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
    love.graphics.draw(shipImage, 755, -15)

    drawProjectile()
    for _, explosion in ipairs(combatScene.explosions) do
        love.graphics.draw(explosion, 0, 0)
    end

    combatScene.fsm.state:draw()
    utility.UI.drawButtons(self.buttons)
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
    combatScene.fsm:setState(combatScene.initialState)
    return scene
end

return combatScene
