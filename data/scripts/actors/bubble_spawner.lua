local engine = require('engine')
local bubble = require('archetypes.bubble')

local function verbose(s)
    print(s)
end

local bubble_spawner = {}

function bubble_spawner.update(eid, dt)
    verbose('bubble_spawner')

    local opens = {}

    traverse_breadth_first({ x = 0, y = 0 }, function (where, tile)
        if tile.type == TILE_NE or tile.type == TILE_SE or tile.type == TILE_NW or tile.type == SW then
            local N = get_tile_type(where.x, where.y + 1)
            local S = get_tile_type(where.x, where.y - 1)
            local E = get_tile_type(where.x + 1, where.y)
            local W = get_tile_type(where.x - 1, where.y)

            if not N or not S or not E or not W then
                opens[#opens + 1] = where
            end
        end
        return true
    end)

    if #opens > 0 then
        for i=1,#opens do
            if math.random() < 1/256 then
                local pick = opens[math.random(#opens)]
                bubble(pick)
                break
            end
        end
    end

    verbose('done.')

    verbose = function () end
end

function bubble_spawner.on_click(eid, pos, loc)
end

return bubble_spawner

