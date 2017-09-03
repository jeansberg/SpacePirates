local gameMap = require("gameMap")
local mapData = require("mapData")
local combatScene = require("combatScene")
local input = require "input"
local utility = require("utility")
local resources = require("resources")
local stateMachine = require("stateMachine")

--[[
    Game Engine module.
    Keeps track of the game state and makes sure that appropriate
    objects are updated and drawn.
]]
local gameEngine = {}

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

local function exitCombat()
    gameEngine.fsm:setState(gameEngine.mapState)
end

local function generateMap()
    local nodes = mapData.getNodes()

    randomizeNodes(nodes)

    return gameMap.newGameMap(nodes)
end

local function drawMenu()
    for i = 1, table.getn(gameEngine.menuState.Options) do
        local drawFunction = function()
            local option = gameEngine.menuState.Options[i]
            love.graphics.print(option[1], option.rect.xPos, option.rect.yPos)
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
        return table.getn(menu.Options)
    else
        return menu.selectedIndex - 1
    end
end

local function MenuDown(menu)
    if menu.selectedIndex == table.getn(menu.Options) then
        return 1
    else
        return menu.selectedIndex + 1
    end
end

local function MenuSelect(menu)
    menu.Options[menu.selectedIndex][2]()
end

gameEngine.menuState = stateMachine.newState()
gameEngine.menuState.Options = {
    {
        "New Game",
        function()
            gameEngine.fsm:setState(gameEngine.mapState)
        end,
        rect = utility.rect(600, 300, 150, 40)
    },
    {
        "Options",
        function()
        end,
        rect = utility.rect(600, 340, 100, 40)
    },
    {
        "Quit",
        function()
            love.event.quit()
        end,
        rect = utility.rect(600, 380, 50, 40)
    }
}
function gameEngine.menuState.enter()
    gameEngine.menuState.selectedIndex = 1
end

function gameEngine.menuState.update(dt)
    local menuInput = input.getMenuInput()
    if menuInput == "up" then
        gameEngine.menuState.selectedIndex = MenuUp(gameEngine.menuState)
    elseif menuInput == "down" then
        gameEngine.menuState.selectedIndex = MenuDown(gameEngine.menuState)
    elseif menuInput == "return" then
        MenuSelect(gameEngine.menuState)
    end

    local mousePos = input.getMouse()
    if mousePos == gameEngine.menuState.lastMousePos then
        return
    end

    for i = 1, table.getn(gameEngine.menuState.Options) do
        local option = gameEngine.menuState.Options[i]
        if input.mouseOver(option.rect) then
            gameEngine.menuState.selectedIndex = i
            gameEngine.menuState.lastMousePos = input.getMouse()
            break
        end
    end
end

function gameEngine.menuState.draw()
    drawMenu(gameEngine.menuState.options)
end

gameEngine.mapState = stateMachine.newState()

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
end

function gameEngine.combatState.update()
    gameEngine.combatScene:update(dt)
end

function gameEngine.combatState.draw()
    gameEngine.combatScene:draw()
end

--[[
    Module interface.
]]
function gameEngine.init()
    math.randomseed(os.time())
    gameMap.init(enterCombat)
    combatScene.init(exitCombat)

    gameEngine.map = generateMap()
    gameEngine.fsm = stateMachine.newStateMachine()
    gameEngine.fsm:setState(gameEngine.menuState)
end

function gameEngine.update(dt)
    gameEngine.fsm.state:update(dt)
end

function gameEngine.draw()
    gameEngine.fsm.state:draw()
end

return gameEngine
