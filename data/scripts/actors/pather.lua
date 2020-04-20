
local pather = {}

function pather.move(state, position, tile_x, tile_y)
    if state.path then
        local dest = state.path[state.path_i]
        local dx = dest.x - position.pos.x
        local dy = dest.y - position.pos.y
        local adx = math.abs(dx)
        local ady = math.abs(dy)

        if get_tile_type(tile_x, tile_y) ~= TILE_CAP or math.random() < 0.5 then
            if adx >= 1/16 then
                position.pos.x = position.pos.x + dx/adx/16
            end

            if ady >= 1/16 then
                position.pos.y = position.pos.y + dy/ady/16
            end
        end

        if adx < 1/16 and ady < 1/16 then
            local next = state.path_i + 1
            if next <= #state.path then
                state.path_i = next
            else
                state.path = nil
            end
        end
    end
end

return pather
