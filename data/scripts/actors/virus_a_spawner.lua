local engine = require('engine')
local virus_a = require('archetypes.virus_a')
local spawner = require('actors.spawner')

local function verbose(s)
    print(s)
end

local virus_a_spawner = {}

function virus_a_spawner.update(eid, dt)
    verbose('virus_a_spawner')

    local spawnloc = spawner(1/512, function (where, tile)
        if tile.type == TILE_CAP then
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
        virus_a(spawnloc)
    end

    verbose('done.')

    verbose = function () end
end

function virus_a_spawner.on_click(eid, pos, loc)
end

return virus_a_spawner
