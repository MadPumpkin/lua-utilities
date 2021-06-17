local TileGraph = {}
TileGraph.__index = TileGraph
TileGraph.directions = {
    up = { x = 0, y = -1 },
    right = { x = 1, y = 0 },
    down = { x = 0, y = 1 },
    left = { x = -1, y = 0 }
}

function TileGraph.new()
    local graph = {
        tiles = {},
        first_tile = nil
    }
    setmetatable(graph, TileGraph)
    return graph
end

function TileGraph:addTile(x, y, value, properties)
    local graph = self
    local next_tile = #self.tiles + 1
    self.tiles[next_tile] = {
        id = next_tile,
        value = value,
        properties = properties or nil,
        coordinate = { x=x, y=y },
        neighborhood = function(self) return graph:getTileNeighborhood(self.coordinate.x, self.coordinate.y) end
    }
    if nil == self.first_tile then
        self.first_tile = self.tiles[1]
    end
    return self.tiles[#self.tiles]
end

function TileGraph:findTileByCoordinate(x, y)
    for k,v in pairs(self.tiles) do
        if v.coordinate.x == x
        and v.coordinate.y == y then
            return k,v
        end
    end
    return nil
end

function TileGraph:getTile(x, y)
    local _, tile = self:findTileByCoordinate(x, y)
    return tile
end

function TileGraph:setTile(x, y, value, properties)
    local tile = self:getTile(x, y)
    if nil ~= tile then
        tile.value = value
        tile.properties = properties
        return tile.value, tile.properties
    else
        return self:addTile(x, y, value, properties)
    end
    return nil
end


function TileGraph:indexAt(x, y)
    local index = self:findTileByCoordinate(x, y)
    return index
end

function TileGraph:getTileNeighborhood(x, y)
    return {
        up=self:getTile(x, y-1),
        right=self:getTile(x+1, y),
        down=self:getTile(x, y+1),
        left=self:getTile(x-1, y)
    }
end

function TileGraph:getTileValue(x, y)
    local tile = self:getTile(x, y)
    if nil ~= tile then
        return tile.value
    else
        return nil
    end
end

function TileGraph:getTileProperties(x, y)
    local tile = self:getTile(x, y)
    if nil ~= tile
    and #tile.properties > 0 then
        return tile.properties
    else
        return nil
    end
end

-- function TileGraph:getPath(Ax, Ay, Bx, By)
--     local An = self:getTileNeighborhood(Ax, Ay)
--     local Ax, 
-- end



return TileGraph