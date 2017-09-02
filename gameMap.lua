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
local nodeHighlight = resources.images.nodeHighlight
local yellowNode = resources.images.yellowNode
local blueNode = resources.images.blueNode
local redNode = resources.images.redNode
local greenNode = resources.images.greenNode
local mermaidShip = resources.images.mermaidShip
local nodeSize = 32
local nodeOffset = nodeSize / 2

local function mouseOnNode(x, y, node)
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

function GameMap:new(nodes, enterCombat)
    local o = {nodes = nodes, enterCombat = enterCombat}
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

function GameMap:update(dt)
    local x, y = input.getMouse()
    self.hoveredNode = nil
    for i = 1, table.getn(self.nodes) do
        if mouseOnNode(x, y, self.nodes[i]) then
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
            self.currentNode = self.hoveredNode

            if self.currentNode.type == "dangerZone" then
                self.enterCombat()
            end
        end
    end
end

function GameMap:draw()
    love.graphics.draw(imgStarMap, 0, 0)

    for i = 1, table.getn(self.nodes) do
        local node = self.nodes[i]
        if node.type == "city" then
            love.graphics.draw(greenNode, node.xPos - nodeOffset, node.yPos - nodeOffset)
        elseif node.type == "dangerZone" then
            love.graphics.draw(redNode, node.xPos - nodeOffset, node.yPos - nodeOffset)
        elseif node.type == "beacon" then
            love.graphics.draw(blueNode, node.xPos - nodeOffset, node.yPos - nodeOffset)
        else
            love.graphics.draw(yellowNode, node.xPos - nodeOffset, node.yPos - nodeOffset)
        end
    end

    local x, y = input.getMouse()
    if self.hoveredNode then
        love.graphics.draw(
            nodeHighlight,
            self.hoveredNode.xPos - nodeOffset - 2,
            self.hoveredNode.yPos - nodeOffset - 2
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
                love.graphics.print(name, node.xPos - nodeOffset - 16, node.yPos - nodeOffset - 16)
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

function gameMap.newGameMap(nodes, enterCombat)
    return GameMap:new(nodes, enterCombat)
end

return gameMap
