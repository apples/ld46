local pather = require('actors.pather')

local function verbose(s)
    print(s)
end

return function(position, state, on_hit)
    verbose('heart_targeter')

    local tile_x = math.floor(position.pos.x + 0.5)
    local tile_y = math.floor(position.pos.y + 0.5)

    local moving_to = state.path and state.path[state.path_i] or { x = tile_x, y = tile_y }

    if not state.path or state.version ~= game_state.board_version then
        verbose('needs new path')
        local path = pathfind(moving_to, { x = 0, y = 0 }, true)

        if path then
            verbose('path found (len = ' .. #path .. ')')
            state.path = path
            state.path_i = 1
            state.version = game_state.board_version
        else
            verbose('path not found')
            state.path = nil
        end
    end

    if tile_x == 0 and tile_y == 0 then
        on_hit()
    end

    pather.move(state, position, tile_x, tile_y)

    verbose('done.')

    verbose = function () end
end
