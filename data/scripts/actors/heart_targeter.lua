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

    if state.path then
        verbose('has path, moving (path_i = ' .. state.path_i .. ', len = ' .. #state.path .. ')')
        local dest = state.path[state.path_i]
        local dx = dest.x - position.pos.x
        local dy = dest.y - position.pos.y
        local adx = math.abs(dx)
        local ady = math.abs(dy)

        if adx >= 1/16 then
            position.pos.x = position.pos.x + dx/adx/16
        end

        if ady >= 1/16 then
            position.pos.y = position.pos.y + dy/ady/16
        end

        if adx < 1/16 and ady < 1/16 then
            verbose('path step reached, advancing')
            local next = state.path_i + 1
            if next <= #state.path then
                state.path_i = next
            end
        end
    end

    if tile_x == 0 and tile_y == 0 then
        on_hit()
    end

    verbose('done.')

    verbose = function () end
end
