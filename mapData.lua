local gameMap = require("gameMap")

local mapData = {}

function mapData.getNodes() 
local n1 = gameMap.newMapNode(1, "System 1", 296, 32, {2})
    local n2 = gameMap.newMapNode(2, "System 2", 216, 72, {1, 3})
    local n3 = gameMap.newMapNode(3, "System 3", 160, 136, {2, 4, 12})
    local n4 = gameMap.newMapNode(4, "System 4", 96, 200, {3, 5})
    local n5 = gameMap.newMapNode(5, "System 5", 32, 272, {4, 6})
    local n6 = gameMap.newMapNode(6, "System 6", 80, 344, {5, 7})
    local n7 = gameMap.newMapNode(7, "System 7", 136, 416, {6, 8, 15})
    local n8 = gameMap.newMapNode(8, "System 8", 176, 512, {7, 9})
    local n9 = gameMap.newMapNode(9, "System 9", 128, 616, {8, 10})
    local n10 = gameMap.newMapNode(10, "System 10", 184, 648, {9, 11})
    local n11 = gameMap.newMapNode(11, "System 11", 248, 688, {10, 28})
    local n12 = gameMap.newMapNode(12, "System 12", 224, 232, {3, 13, 14})
    local n13 = gameMap.newMapNode(13, "System 13", 360, 240, {12, 14, 16, 20})
    local n14 = gameMap.newMapNode(14, "System 14", 304, 352, {12, 13, 15})
    local n15 = gameMap.newMapNode(15, "System 15", 256, 464, {7, 14})
    local n16 = gameMap.newMapNode(16, "System 16", 360, 136, {13, 17, 19})
    local n17 = gameMap.newMapNode(17, "System 17", 480, 72, {16, 18})
    local n18 = gameMap.newMapNode(18, "System 18", 600, 112, {17, 19, 21})
    local n19 = gameMap.newMapNode(19, "System 19", 496, 200, {16, 18, 20, 22})
    local n20 = gameMap.newMapNode(20, "System 20", 464, 272, {13, 19})
    local n21 = gameMap.newMapNode(21, "System 21", 648, 216, {18, 22})
    local n22 = gameMap.newMapNode(22, "System 22", 552, 296, {19, 21, 23, 29})
    local n23 = gameMap.newMapNode(23, "System 23", 536, 392, {22, 24, 31})
    local n24 = gameMap.newMapNode(24, "System 24", 408, 384, {23, 25})
    local n25 = gameMap.newMapNode(25, "System 25", 432, 456, {24, 26})
    local n26 = gameMap.newMapNode(26, "System 26", 448, 528, {25, 27})
    local n27 = gameMap.newMapNode(27, "System 27", 408, 568, {26, 28, 34})
    local n28 = gameMap.newMapNode(28, "System 28", 336, 624, {11, 27})
    local n29 = gameMap.newMapNode(29, "System 29", 680, 360, {22, 30})
    local n30 = gameMap.newMapNode(30, "System 30", 680, 400, {29, 31})
    local n31 = gameMap.newMapNode(31, "System 31", 584, 424, {23, 30, 32})
    local n32 = gameMap.newMapNode(32, "System 32", 640, 544, {31, 33})
    local n33 = gameMap.newMapNode(33, "System 33", 552, 616, {32, 34})
    local n34 = gameMap.newMapNode(34, "System 34", 464, 680, {27, 33})

    local nodes = {
        n1,
        n2,
        n3,
        n4,
        n5,
        n6,
        n7,
        n8,
        n9,
        n10,
        n11,
        n12,
        n13,
        n14,
        n15,
        n16,
        n17,
        n18,
        n19,
        n20,
        n21,
        n22,
        n23,
        n24,
        n25,
        n26,
        n27,
        n28,
        n29,
        n30,
        n31,
        n32,
        n33,
        n34
    }

    return nodes
end

return mapData