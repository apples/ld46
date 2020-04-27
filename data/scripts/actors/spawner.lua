if USE_JAM_VERSION then return require('jam_version.actors/spawner') end

local random_picker = require('random_picker')

return function(rate, valid_tiles, config)
    config = config or {}

    local picker = random_picker.new()
    local count = 0

    traverse_breadth_first({ x = 0, y = 0 }, function (where, tile)
        if config.mindepth and where.depth < config.mindepth then
            return true
        end
        if config.maxdepth and where.depth > config.maxdepth then
            return false
        end

        for _,v in ipairs(valid_tiles) do
            if tile.type == v then
                local N = get_tile_type(where.x, where.y + 1)
                local S = get_tile_type(where.x, where.y - 1)
                local E = get_tile_type(where.x + 1, where.y)
                local W = get_tile_type(where.x - 1, where.y)

                if not (N and S and E and W) then
                    count = count + 1
                    picker(where)
                end

                break
            end
        end

        return true
    end)

    local chance = 1 - math.pow(1 - rate, count)

    if math.random() < chance then
        return picker.result[1]
    end
end
