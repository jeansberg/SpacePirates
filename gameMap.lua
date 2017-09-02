local resources = require("resources")
local input = require("input")

--[[
    Game Map module.
    Exposes functions for creating map nodes and game maps. 
]]
local gameMap = {}

--[[
    Local fields and functions.
]]
local imgStarMap = resources.images.starMap
local highlightNode = resources.images.highlightNode
local nodeSize = 32
local nodeOffset = nodeSize / 2

local function mouseHover(x, y, node)
    if
        x > node.xPos - nodeOffset and x < node.xPos + nodeOffset and y > node.yPos - nodeOffset and
            y < node.yPos + nodeOffset
     then
        return true
    end

    return false
end

--[[
    MapNode class.
    A node on the map. Has an id and links to other nodes.
    Has x and y positions for drawing a representation of the map.
]]
local MapNode = {}
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
GameMap.currentNode = {}

function GameMap:new(nodes)
    local o = {nodes = nodes}
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

function GameMap:update(dt)
    local x, y = input.getMouse()
    self.hoveredNode = nil
    for i = 1, table.getn(self.nodes) do
        if mouseHover(x, y, self.nodes[i]) then
            self.hoveredNode = self.nodes[i]
            break
        end
    end
end

function GameMap:draw()
    love.graphics.draw(imgStarMap, 0, 0)

    local x, y = input.getMouse()
    if self.hoveredNode then
        love.graphics.draw(
            highlightNode,
            self.hoveredNode.xPos - nodeOffset,
            self.hoveredNode.yPos - nodeOffset
        )
        resources.printWithFont(
            "smallFont",
            function()
                love.graphics.print(
                    self.hoveredNode.name,
                    self.hoveredNode.xPos - nodeOffset,
                    self.hoveredNode.yPos - nodeOffset
                )
            end
        )
    end
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
