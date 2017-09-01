--[[
    Game Map module.
    Exposes functions for creating map nodes and game maps. 
]]

local gameMap = {}

--[[
    Local fields and functions.
]]

local nodeSize = 4
local nodeOffset = nodeSize / 2

--[[
    MapNode class.
    A node on the map. Has an id and links to other nodes.
    Has x and y positions for drawing a representation of the map.
]]

local MapNode = {}
MapNode.id = 0
MapNode.links = {}

function MapNode:new(id, xPos, yPos, links)
    local o = {id = id, xPos = xPos, yPos = yPos, links = links}
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
    if currentNode.links[node.id] then
        currentNode = node
        return true
    end

    return false
end

function GameMap:draw()
    

    -- Draw links
    local linksDrawn = {}
    for i = 1, table.getn(self.nodes)
        local node = self.nodes[i]
        for j = 1, table.getn(node.links)
            local linkedNode = node.links[j]
            if not linksDrawn[{node, linkedNode}] and not linksDrawn[{linkedNode, node}] then
                love.graphics.line(node.xPos + nodeOffset, node.yPos + nodeOffset, linkedNode.xPos + nodeOffset, linkedNode.yPos + nodeOffset)
            end
        end
    end

    -- Draw nodes on top of links
    for i = 1, table.getn(self.nodes)
        local node = self.nodes[i]
        love.graphics.circle("fill", node.xPos, node.yPos, nodeSize, nodeSize)
    end
end

--[[
    Module interface.
]]

function GameMap.newMapNode(id, xPos, yPos, links)
    return MapNode:new(id, xPos, yPos, links)
end

function GameMap.newGameMap(nodes)
    return GameMap:new(nodes)
end

return gameMap