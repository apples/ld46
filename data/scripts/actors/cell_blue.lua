local engine = require('engine')

local cell_blue = {}

function cell_blue.update(eid, dt)
    local position = engine.entities:get_component(eid, component.position)
    local script = engine.entities:get_component(eid, component.script)
    local state = script.state

    local tile_x = math.floor(position.pos.x + 0.5)
    local tile_y = math.floor(position.pos.y + 0.5)

    local function find_new_target()
        state.path = nil

        local best_score = nil
        local potential_targets = {}

        traverse_breadth_first(function (where, tile)
            if tile.type == TILE_CAP then
                local score = math.abs(where.x - tile_x) + math.abs(where.y - tile_y)
                if best_score == nil or score < best_score then
                    best_score = score
                    potential_targets = { where }
                elseif score == best_score then
                    potential_targets[#potential_targets + 1] = where
                end
                return false
            end
            return true
        end)

        if #potential_targets > 0 then
            local roll = math.random(#potential_targets)
            state.target = potential_targets[roll]
        end
    end

    if not state.target then
        find_new_target()
    else
        local target_tile = get_tile(state.target.x, state.target.y)
        if not target_tile or target_tile.type ~= TILE_CAP then
            find_new_target()
        end
    end

    if state.target then
        if not state.path or state.path.version ~= game_state.board_version then
            local path = pathfind({ x = tile_x, y = tile_y }, state.target)

            if path then
                state.path = {
                    path = path,
                    version = game_state.board_version
                }
            else
                state.target = nil
                state.path = nil
            end
        end
    end

    if state.path then
        local dest = state.path.path
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
            local next = state.path.path.next
            if next then
                state.path.path = next
            end
        end
    end

    local cur_tile = get_tile(tile_x, tile_y)

    if cur_tile and cur_tile.type == TILE_CAP then
        state.timer = (state.timer or 0) + dt
        if state.timer >= 1 then
            local high_priority = {}
            local low_priority = {}

            local N = get_tile_type(tile_x, tile_y + 1)
            local S = get_tile_type(tile_x, tile_y - 1)
            local E = get_tile_type(tile_x + 1, tile_y)
            local W = get_tile_type(tile_x - 1, tile_y)

            local N_connected = (N == TILE_SE or N == TILE_SW or N == TILE_CROSS)
            local S_connected = (S == TILE_NE or S == TILE_NW or S == TILE_CROSS)
            local E_connected = (E == TILE_NW or E == TILE_SW or E == TILE_CROSS)
            local W_connected = (W == TILE_NE or W == TILE_SE or W == TILE_CROSS)

            if N_connected then
                if not E then
                    high_priority[#high_priority + 1] = TILE_NE
                elseif E_connected then
                    low_priority[#low_priority + 1] = TILE_NE
                end
                if not W then
                    high_priority[#high_priority + 1] = TILE_NW
                elseif W_connected then
                    low_priority[#low_priority + 1] = TILE_NW
                end
            end

            if S_connected then
                if not E then
                    high_priority[#high_priority + 1] = TILE_SE
                elseif E_connected then
                    low_priority[#low_priority + 1] = TILE_SE
                end
                if not W then
                    high_priority[#high_priority + 1] = TILE_SW
                elseif W_connected then
                    low_priority[#low_priority + 1] = TILE_SW
                end
            end

            if E_connected then
                if not N then
                    high_priority[#high_priority + 1] = TILE_NE
                elseif N_connected then
                    low_priority[#low_priority + 1] = TILE_NE
                end
                if not S then
                    high_priority[#high_priority + 1] = TILE_SE
                elseif S_connected then
                    low_priority[#low_priority + 1] = TILE_SE
                end
            end

            if W_connected then
                if not N then
                    high_priority[#high_priority + 1] = TILE_NW
                elseif N_connected then
                    low_priority[#low_priority + 1] = TILE_NW
                end
                if not S then
                    high_priority[#high_priority + 1] = TILE_SW
                elseif S_connected then
                    low_priority[#low_priority + 1] = TILE_SW
                end
            end

            local decision = nil

            if #high_priority > 0 then
                local roll = math.random(#high_priority)
                decision = high_priority[roll]
            elseif #low_priority > 0 then
                local roll = math.random(#low_priority)
                decision = low_priority[roll]
            end

            if decision then
                set_tile(tile_x, tile_y, decision)

                if decision == TILE_NE then
                    if not N then
                        set_tile(tile_x, tile_y + 1, TILE_CAP)
                    end
                    if not E then
                        set_tile(tile_x + 1, tile_y, TILE_CAP)
                    end
                end

                if decision == TILE_SE then
                    if not S then
                        set_tile(tile_x, tile_y - 1, TILE_CAP)
                    end
                    if not E then
                        set_tile(tile_x + 1, tile_y, TILE_CAP)
                    end
                end

                if decision == TILE_NW then
                    if not N then
                        set_tile(tile_x, tile_y + 1, TILE_CAP)
                    end
                    if not W then
                        set_tile(tile_x - 1, tile_y, TILE_CAP)
                    end
                end

                if decision == TILE_SW then
                    if not S then
                        set_tile(tile_x, tile_y - 1, TILE_CAP)
                    end
                    if not W then
                        set_tile(tile_x - 1, tile_y, TILE_CAP)
                    end
                end

                state.timer = 0
            end
        end
    else
        state.timer = 0
    end
end

function cell_blue.on_click(eid, pos, loc)
end

return cell_blue

