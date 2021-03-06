local engine = require('engine')
local virus_b = require('archetypes.virus_b')
local spawner = require('actors.spawner')

local function verbose(s)
    print(s)
end

local virus_b_spawner = {}

function virus_b_spawner.update(eid, dt)
    verbose('virus_b_spawner')

    local spawnloc = spawner(1/1024, function (where, tile)
        if tile.type == TILE_NE or tile.type == TILE_SE or tile.type == TILE_NW or tile.type == TILE_SW then
            local N = get_tile_type(where.x, where.y + 1)
            local S = get_tile_type(where.x, where.y - 1)
            local E = get_tile_type(where.x + 1, where.y)
            local W = get_tile_type(where.x - 1, where.y)

            if not N or not S or not E or not W then
                return true
            end
        end
        return false
    end)

    if spawnloc then
        if math.random(spawnloc.depth) == 1 then
            virus_b(spawnloc)
        end
    end

    verbose('done.')

    verbose = function () end
end

function virus_b_spawner.on_click(eid, pos, loc)
end

return virus_b_spawner
