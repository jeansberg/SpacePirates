local resources = require("resources")
local input = require("input")
local utility = require("utility")

local warpDrive = resources.sounds.warpDrive

--[[
    Game Map module.
    Exposes functions for creating map nodes and game maps. 
]]
local gameMap = {}
function gameMap.init(enterCombat, enterCity, enterMenu)
    gameMap.enterCombat = enterCombat
    gameMap.enterCity = enterCity
    gameMap.enterMenu = enterMenu
end

--[[
    Local fields and functions.
]]
local imgStarMap = resources.images.starMap
local nodeHighlight = resources.images.nodeHighlight
local yellowNode = resources.images.yellowNode
local blueNode = resources.images.blueNode
local redNode = resources.images.redNode
local greenNode = resources.images.greenNode
local mermaidShip = resources.images.mermaidShip
local nodeSize = 32
local nodeRadius = nodeSize / 2
local nodeClickRadius = nodeRadius + 8

--[[
    MapNode class.
    A node on the map. Has an id and links to other nodes.
    Has x and y positions for drawing a representation of the map.
]]
local MapNode = {}
MapNode.type = "normal"
MapNode.id = 0
MapNode.links = {}

function MapNode:new(id, name, xPos, yPos, links)
    local o = {id = id, name = name, xPos = xPos, yPos = yPos, links = links}
    setmetatable(o, self)
    self.__index = self
    return o
end

--[[
    GameMap class.
    A collection of nodes.
    Keeps track of the current node and allows movement to other linked nodes.
]]
local GameMap = {}
GameMap.nodes = {}
GameMap.buttons = {
    utility.newButton(
        40,
        700,
        "Menu",
        true,
        function()
            gameMap.enterMenu()
        end,
        "smallFont"
    )
}

function GameMap:new(nodes)
    local o = {nodes = nodes}
    o.currentNode = o.nodes[1]
    setmetatable(o, self)
    self.__index = self
    return o
end

function GameMap:moveToNode(node)
    if self.currentNode.links[node.id] then
        self.currentNode = node
        return true
    end

    return false
end

local function getEncounterType()
    return "combat"
end

local function enterScene(node)
    local type = getEncounterType()

    if type == "combat" then
        gameMap.enterCombat()
    end
    --[[
    if node.type == "dangerZone" then
        gameMap.enterCombat()
    elseif node.type == "city" then
        gameMap.enterCity()
    end
    ]]
end

function GameMap:update(dt)
    utility.updateButtons(self.buttons)

    self.hoveredNode = nil
    for i = 1, table.getn(self.nodes) do
        local node = self.nodes[i]
        local rect = {
            xPos = node.xPos - nodeClickRadius,
            yPos = node.yPos - nodeClickRadius,
            width = nodeClickRadius * 2,
            height = nodeClickRadius * 2
        }
        if input.mouseOver(rect) then
            self.hoveredNode = self.nodes[i]
            break
        end
    end

    if self.hoveredNode and input.getLeftClick() then
        local canTravel = false
        for i = 1, table.getn(self.currentNode.links) do
            if self.currentNode.links[i] == self.hoveredNode.id then
                canTravel = true
                break
            end
        end

        if canTravel then
            resources.playSound(warpDrive)
            self.currentNode = self.hoveredNode
            enterScene(self.currentNode)
            return
        end
    end
end

function GameMap:draw()
    love.graphics.draw(imgStarMap, 0, 0)
    utility.drawButtons(self.buttons)

    for i = 1, table.getn(self.nodes) do
        local node = self.nodes[i]
        if node.type == "city" then
            love.graphics.draw(greenNode, node.xPos - nodeRadius, node.yPos - nodeRadius)
        elseif node.type == "dangerZone" then
            love.graphics.draw(redNode, node.xPos - nodeRadius, node.yPos - nodeRadius)
        elseif node.type == "beacon" then
            love.graphics.draw(blueNode, node.xPos - nodeRadius, node.yPos - nodeRadius)
        else
            love.graphics.draw(yellowNode, node.xPos - nodeRadius, node.yPos - nodeRadius)
        end
    end

    local x, y = input.getMouse()
    if self.hoveredNode then
        love.graphics.draw(
            nodeHighlight,
            self.hoveredNode.xPos - nodeRadius - 2,
            self.hoveredNode.yPos - nodeRadius - 2
        )
        resources.printWithFont(
            "smallFont",
            function()
                local node = self.hoveredNode
                local name = node.name
                if node.type == "dangerZone" then
                    name = "Danger Zone"
                elseif node.type == "city" then
                    name = "Merchant City"
                elseif node.type == "beacon" then
                    name = "Distress Beacon"
                end
                love.graphics.print(name, node.xPos - nodeRadius - 16, node.yPos - nodeRadius - 16)
            end
        )
    end

    love.graphics.draw(mermaidShip, self.currentNode.xPos, self.currentNode.yPos, 0, 0.1, 0.1)
end

--[[
    Module interface.
]]
function gameMap.newMapNode(id, name, xPos, yPos, links)
    return MapNode:new(id, name, xPos, yPos, links)
end

function gameMap.newGameMap(nodes)
    return GameMap:new(nodes)
end

return gameMap
