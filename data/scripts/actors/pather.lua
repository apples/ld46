if USE_JAM_VERSION then return require('jam_version.actors/pather') end


local pather = {}

function pather.move(state, position, tile_x, tile_y, final_dest)
    if state.path or final_dest then
        local dest = state.path and state.path[state.path_i] or final_dest
        local dx = dest.x - position.pos.x
        local dy = dest.y - position.pos.y
        local adx = math.abs(dx)
        local ady = math.abs(dy)

        local on_cap = get_tile_type(tile_x, tile_y) == TILE_CAP

        if on_cap then
            state.cap_tick = (state.cap_tick or 0) + 1
            if state.cap_tick == 4 then
                state.cap_tick = 1
            end
        end

        if not on_cap or state.cap_tick == 3 then
            if adx >= 1/16 then
                position.pos.x = position.pos.x + dx/adx/16
            end

            if ady >= 1/16 then
                position.pos.y = position.pos.y + dy/ady/16
            end
        end

        if state.path and adx < 1/16 and ady < 1/16 then
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
