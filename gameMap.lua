--[[
    Game Map module.
    Exposes functions for creating map nodes and game maps. 
]]
local gameMap = {}

--[[
    Local fields and functions.
]]
local nodeSize = 8
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
    if self.currentNode.links[node.id] then
        self.currentNode = node
        return true
    end

    return false
end

function GameMap:draw()
    -- Draw links
    local linksDrawn = {}
    for i = 1, table.getn(self.nodes) do -- loop all nodes
        local originNode = self.nodes[i]
        for j = 1, table.getn(originNode.links) do -- loop all linked nodes
            local linkedNode = self.nodes[originNode.links[j]]
            print("Linking " .. originNode.id .. " and " .. linkedNode.id)
            if
                linkedNode and not linksDrawn[{originNode, linkedNode}] and
                    not linksDrawn[{linkedNode, originNode}]
             then
                love.graphics.line(
                    originNode.xPos + nodeOffset,
                    originNode.yPos + nodeOffset,
                    linkedNode.xPos + nodeOffset,
                    linkedNode.yPos + nodeOffset
                )
            end
        end
    end

    -- Draw nodes on top of links
    for i = 1, table.getn(self.nodes) do
        local node = self.nodes[i]
        love.graphics.circle("fill", node.xPos, node.yPos, nodeSize, nodeSize)
        love.graphics.print(node.id, node.xPos, node.yPos)
    end
end

--[[
    Module interface.
]]
function gameMap.newMapNode(id, xPos, yPos, links)
    return MapNode:new(id, xPos, yPos, links)
end

function gameMap.newGameMap(nodes)
    return GameMap:new(nodes)
end

return gameMap
