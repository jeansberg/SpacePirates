--[[
    Game Map module.
    Exposes functions for creating map nodes and game maps. 
]]

local gameMap = {}

--[[
    MapNode class.
    A node on the map. Has an id and links to other nodes.
]]

local MapNode = {}
MapNode.id = 0
MapNode.links = {}

function MapNode:new(id, links)
    local o = {id = id, links = links}
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

--[[
    Module interface.
]]

function GameMap.newMapNode(id, links)
    return MapNode:new(id, links)
end

function GameMap.newGameMap(nodes)
    return GameMap:new(nodes)
end

return gameMap