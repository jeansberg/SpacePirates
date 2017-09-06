local gameMap = require("gameMap")
local mapData = require("mapData")
local combatScene = require("combatScene")
local cityScene = require("cityScene")
local input = require "input"
local utility = require("utility")
local resources = require("resources")
local stateMachine = require("stateMachine")
local player = require("player")
local pirate = require("pirate")
local highLevelPirate = require("highLevelPirate")
local keyStarPirate = require("keyStarPirate")
local merchantShip = require("merchantShip")

local starrySky = resources.images.starrySky

local titleTheme = resources.music.titleTheme
local battleTheme = resources.music.battleTheme
local mainTheme = resources.music.mainTheme
local cityTheme = resources.music.cityTheme
local warp = resources.sounds.warpDrive

--[[
    Game Engine module.
    Keeps track of the game state and makes sure that appropriate
    objects are updated and drawn.
]]
local gameEngine = {}
gameEngine.running = false

--[[
    Local fields and functions.
]]
local function addTypeToRandom(nodes, type, isSpecial)
    local selectedIndex
    repeat
        selectedIndex = math.random(1, table.getn(nodes))
    until not isSpecial[selectedIndex]

    nodes[selectedIndex].type = type
    isSpecial[selectedIndex] = true
end

local function shuffle(tbl)
    local size = table.getn(tbl)
    for i = size, 1, -1 do
        local rand = math.random(size)
        tbl[i], tbl[rand] = tbl[rand], tbl[i]
    end
    return tbl
end

local function getRandomUpgrade(node)
    local roll = math.random(1, 3)
    if roll == 1 then
        table.insert(node.upgrades, {"armor"})
    elseif roll == 2 then
        table.insert(node.upgrades, {"crit"})
    elseif roll == 3 then
        table.insert(node.upgrades, {"dodge"})
    end
end

local function getRandomGun(weapons)
    local specialWeapons = {}
    if not weapons["debuff"] then
        table.insert(specialWeapons, "debuff")
    end
    if not weapons["crit"] then
        table.insert(specialWeapons, "crit")
    end
    if not weapons["pierce"] then
        table.insert(specialWeapons, "pierce")
    end

    local roll = math.random(1, table.getn(specialWeapons))
    local receivedWeapon = specialWeapons[roll]
    table.insert(weapons, {receivedWeapon = true})
end

local function stockStoreInventory(nodes)
    local weapons = {}
    getRandomGun(weapons)
    getRandomGun(weapons)
    local counter = 0

    for i = 1, table.getn(nodes) do
        local node = nodes[i]
        if node.type == "city" then
            counter = counter + 1
            node.upgrades = {}
            node.weapons = {}
            getRandomUpgrade(node)
            getRandomUpgrade(node)

            if counter < 3 then
                table.insert(node.weapons, weapons[counter])
            end
        end
    end
end

local function addNamesToNormal(nodes)
    local names = {
        "Asinus",
        "Magi",
        "Sacerdos",
        "Imperatrix",
        "Caesar",
        "Antistes",
        "Amantium",
        "Curru",
        "Viribus",
        "Eremita",
        "Fortuna",
        "Lustitiae",
        "Criminalis",
        "Mors",
        "Temperantia",
        "Diaboli",
        "Turrim",
        "Stella",
        "Luna",
        "Solis",
        "Judicii",
        "Mundi"
    }

    names = shuffle(names)

    local nameIndex = 1
    for i = 1, table.getn(nodes) do
        local node = nodes[i]
        if node.type == "normal" or node.type == "key" then
            node.name = names[nameIndex]
            nameIndex = nameIndex + 1
        end
    end
end

-- Randomly chooses nodes to get special types
local function randomizeNodes(nodes)
    local isSpecial = {}
    -- Randomize cities
    for _ = 1, 4 do
        addTypeToRandom(nodes, "city", isSpecial)
    end
    -- Randomize danger zones
    for _ = 1, 8 do
        addTypeToRandom(nodes, "dangerZone", isSpecial)
    end

    addTypeToRandom(nodes, "key", isSpecial)
    addNamesToNormal(nodes)
    stockStoreInventory(nodes)
end

local function enterCombat(enemyType)
    gameEngine.fsm:setState(gameEngine.combatState)

    local enemy = {}
    print("type: " .. enemyType)
    if enemyType == "pirate" then
        enemy = pirate.newPirate()
    elseif enemyType == "highLevelPirate" then
        enemy = highLevelPirate.newHighLevelPirate()
    elseif enemyType == "keyStarPirate" then
        enemy = keyStarPirate.newKeyStarPirate()
    elseif enemyType == "merchantShip" then
        enemy = merchantShip.newMerchantShip()
    end
    gameEngine.combatScene = combatScene.newCombatScene(gameEngine.player, enemy)
end

local function enterCity(node)
    gameEngine.fsm:setState(gameEngine.cityState)
    gameEngine.cityScene = cityScene.newCityScene(node, gameEngine.player)
end

local function exitScene(message)
    if message == "fledCombat" then
        print("Player fled combat.\n")
        resources.playSound(warp)
    elseif message == "diedFleeing" then
        print("Player attempted to flee but took too much damage.\n")
    end
    gameEngine.fsm:setState(gameEngine.mapState)
end

local function enterMenu()
    gameEngine.fsm:setState(gameEngine.menuState)
end

local function generateMap()
    local nodes = mapData.getNodes()

    randomizeNodes(nodes)

    return gameMap.newGameMap(nodes)
end

local function scrollSky(dt)
    local pos = gameEngine.menuState.skyPosition
    if pos > -1280 then
        pos = pos - dt * 20
    else
        pos = 0
    end

    return pos
end

local function drawSky()
    love.graphics.draw(starrySky, gameEngine.menuState.skyPosition, 0)
    love.graphics.draw(starrySky, gameEngine.menuState.skyPosition + 1280, 0)
end

local function drawMenu()
    for i = 1, table.getn(gameEngine.menuState.Buttons) do
        local drawFunction = function()
            local option = gameEngine.menuState.Buttons[i]
            if option.visible then
                love.graphics.print(option.text, option.xPos, option.yPos)
            end
        end

        if i == gameEngine.menuState.selectedIndex then
            resources.drawWithColor(
                255,
                0,
                0,
                255,
                function()
                    resources.printWithFont("largeFont", drawFunction)
                end
            )
        else
            resources.printWithFont("largeFont", drawFunction)
        end
    end
end

local function MenuUp(menu)
    if menu.selectedIndex == 1 then
        menu.selectedIndex = table.getn(menu.Buttons)
    else
        menu.selectedIndex = menu.selectedIndex - 1
    end

    if not menu.Buttons[menu.selectedIndex].visible then
        MenuUp(menu)
    end
    menu.Buttons[menu.selectedIndex]:focus()
end

local function MenuDown(menu)
    if menu.selectedIndex == table.getn(menu.Buttons) then
        menu.selectedIndex = 1
    else
        menu.selectedIndex = menu.selectedIndex + 1
    end

    if not menu.Buttons[menu.selectedIndex].visible then
        MenuDown(menu)
    end
    menu.Buttons[menu.selectedIndex]:focus()
end

local function MenuSelect(menu)
    menu.Buttons[menu.selectedIndex].execute()
end

local function setOptionVisible(option, visible)
    option.visible = visible
end

gameEngine.menuState = stateMachine.newState()
gameEngine.menuState.Buttons = {
    utility.newButton(
        500,
        260,
        "Resume Game",
        false,
        true,
        function()
            gameEngine.fsm:setState(gameEngine.mapState)
        end
    ),
    utility.newButton(
        500,
        300,
        "New Game",
        true,
        true,
        function()
            gameEngine.running = true
            gameEngine.map = generateMap()
            gameEngine.player = player.newPlayer()
            resources.restartMusic(mainTheme)
            gameEngine.fsm:setState(gameEngine.mapState)
        end
    ),
    utility.newButton(
        500,
        340,
        "Options",
        true,
        true,
        function()
        end
    ),
    utility.newButton(
        500,
        380,
        "Quit",
        true,
        true,
        function()
            love.event.quit()
        end
    )
}

function gameEngine.menuState:enter()
    if gameEngine.running then
        gameEngine.menuState.selectedIndex = 1
    else
        gameEngine.menuState.selectedIndex = 2
    end
end

function gameEngine.menuState:update(dt)
    gameEngine.menuState.skyPosition = scrollSky(dt)

    if gameEngine.running then
        setOptionVisible(gameEngine.menuState.Buttons[1], true)
    end

    local menuInput = input.getMenuInput()
    if menuInput == "up" then
        MenuUp(gameEngine.menuState)
    elseif menuInput == "down" then
        MenuDown(gameEngine.menuState)
    elseif menuInput == "return" then
        MenuSelect(gameEngine.menuState)
    end

    local mousePos = input.getMouse()
    -- if mousePos == gameEngine.menuState.lastMousePos then
    --     return
    -- end

    for i = 1, table.getn(gameEngine.menuState.Buttons) do
        local option = gameEngine.menuState.Buttons[i]
        if input.mouseOver(option:getRect()) then
            if option.visible then
                gameEngine.menuState.selectedIndex = i
                if not gameEngine.menuState.lastIndex == gameEngine.menuState.selectedIndex then
                    gameEngine.menuState.Buttons[gameEngine.menuState.selectedIndex]:focus()
                end
                gameEngine.menuState.lastIndex = gameEngine.menuState.selectedIndex
                if input.getLeftClick() then
                    MenuSelect(gameEngine.menuState)
                end
                break
            end
        end
    end
end

function gameEngine.menuState:draw()
    drawSky()

    drawMenu(gameEngine.menuState.options)
end

gameEngine.mapState = stateMachine.newState()

function gameEngine.mapState:enter()
    --print("Map is " .. gameEngine.map)
    print("Enter map state\n")
    resources.playMusic(mainTheme)
end

function gameEngine.mapState:update(dt)
    gameEngine.map:update(dt)

    if input.getEsc() then
        gameEngine.fsm:setState(gameEngine.menuState)
    end
end

function gameEngine.mapState:draw()
    gameEngine.map:draw()
end

gameEngine.combatState = stateMachine.newState()
function gameEngine.combatState:enter()
    resources.playMusic(battleTheme)
end

function gameEngine.combatState:update(dt)
    gameEngine.combatScene:update(dt)
end

function gameEngine.combatState:draw()
    gameEngine.combatScene:draw()
end

gameEngine.cityState = stateMachine.newState()
function gameEngine.cityState.enter()
    resources.playMusic(cityTheme)
end

function gameEngine.cityState:update()
    gameEngine.cityScene:update(dt)
end

function gameEngine.cityState:draw()
    gameEngine.cityScene:draw()
end

--[[
    Module interface.
]]
function gameEngine.init()
    math.randomseed(os.time())
    gameMap.init(enterCombat, enterCity, enterMenu)
    combatScene.init(exitScene)
    cityScene.init(exitScene)

    gameEngine.fsm = stateMachine.newStateMachine()
    gameEngine.fsm:setState(gameEngine.menuState)
    gameEngine.menuState.skyPosition = 0

    resources.playMusic(titleTheme)
end

function gameEngine.update(dt)
    gameEngine.fsm.state:update(dt)
end

function gameEngine.draw()
    gameEngine.fsm.state:draw()
end

return gameEngine
