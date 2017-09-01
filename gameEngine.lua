local gameMap = require("gameMap")

local gameEngine = {}

gameEngine.map = {}

function gameEngine.init()
    local n1 = gameMap.newMapNode(1, 10, 10, {2, 3, 4})
    local n2 = gameMap.newMapNode(2, 40, 60, {1, 3, 5})
    local n3 = gameMap.newMapNode(3, 60, 40, {2, 3, 1, 5})
    local n4 = gameMap.newMapNode(4, 180, 20, {1})
    local n5 = gameMap.newMapNode(5, 100, 100, {2, 3})

    gameEngine.map = gameMap.newGameMap({n1, n2, n3, n4, n5})
end

function gameEngine.update(dt)

end

function gameEngine.draw()
    gameEngine.map:draw()
end

return gameEngine