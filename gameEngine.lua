local gameMap = require("gameMap")
local mapData = require("mapData")
local combatScene = require("combatScene")
local cityScene = require("cityScene")
local input = require "input"
local utility = require("utility")
local resources = require("resources")
local stateMachine = require("stateMachine")

local titleTheme = resources.music.titleTheme
local battleTheme = resources.music.battleTheme
local mainTheme = resources.music.mainTheme
local cityTheme = resources.music.cityTheme

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
        if node.type == "normal" then
            node.name = names[nameIndex]
            nameIndex = nameIndex + 1
        end
    end
end

-- Randomly chooses nodes to get special types
local function randomizeNodes(nodes)
    local isSpecial = {}
    -- Randomize cities
    for _ = 1, 3 do
        addTypeToRandom(nodes, "city", isSpecial)
    end
    -- Randomize beacons
    for _ = 1, 4 do
        addTypeToRandom(nodes, "beacon", isSpecial)
    end
    -- Randomize danger zones
    for _ = 1, 5 do
        addTypeToRandom(nodes, "dangerZone", isSpecial)
    end

    addTypeToRandom(nodes, "key", isSpecial)

    addNamesToNormal(nodes)
end

local function enterCombat()
    gameEngine.fsm:setState(gameEngine.combatState)
end

local function enterCity()
    gameEngine.fsm:setState(gameEngine.cityState)
end

local function exitScene()
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
        function()
            gameEngine.fsm:setState(gameEngine.mapState)
        end
    ),
    utility.newButton(
        500,
        300,
        "New Game",
        true,
        function()
            gameEngine.running = true
            gameEngine.map = generateMap()
            resources.restartMusic(mainTheme)
            gameEngine.fsm:setState(gameEngine.mapState)
        end
    ),
    utility.newButton(
        500,
        340,
        "Options",
        true,
        function()
        end
    ),
    utility.newButton(
        500,
        380,
        "Quit",
        true,
        function()
            love.event.quit()
        end
    )
}

function gameEngine.menuState.enter()
    if gameEngine.running then
        gameEngine.menuState.selectedIndex = 1
    else
        gameEngine.menuState.selectedIndex = 2
    end
end

function gameEngine.menuState.update(dt)
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
            gameEngine.menuState.selectedIndex = i
            if not gameEngine.menuState.lastIndex == gameEngine.menuState.selectedIndex then
                print("FOCUS")
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

function gameEngine.menuState.draw()
    drawMenu(gameEngine.menuState.options)
end

gameEngine.mapState = stateMachine.newState()

function gameEngine.mapState.enter()
    resources.playMusic(mainTheme)
end

function gameEngine.mapState.update(dt)
    gameEngine.map:update(dt)

    if input.getEsc() then
        gameEngine.fsm:setState(gameEngine.menuState)
    end
end

function gameEngine.mapState.draw()
    gameEngine.map:draw()
end

gameEngine.combatState = stateMachine.newState()
function gameEngine.combatState.enter()
    gameEngine.combatScene = combatScene.newCombatScene()
    resources.playMusic(battleTheme)
end

function gameEngine.combatState.update()
    gameEngine.combatScene:update(dt)
end

function gameEngine.combatState.draw()
    gameEngine.combatScene:draw()
end

gameEngine.cityState = stateMachine.newState()
function gameEngine.cityState.enter()
    gameEngine.cityScene = cityScene.newCityScene()
    resources.playMusic(cityTheme)
end

function gameEngine.cityState.update()
    gameEngine.cityScene:update(dt)
end

function gameEngine.cityState.draw()
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

    resources.playMusic(titleTheme)
end

function gameEngine.update(dt)
    gameEngine.fsm.state:update(dt)
end

function gameEngine.draw()
    gameEngine.fsm.state:draw()
end

return gameEngine
