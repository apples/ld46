local engine = require('engine')
local pather = require('actors.pather')

local function verbose(s)
    print(s)
end

local cell_blue = {}

function cell_blue.update(eid, dt)
    verbose('cell_blue')

    local position = engine.entities:get_component(eid, component.position)
    local script = engine.entities:get_component(eid, component.script)
    local state = script.state

    local tile_x = math.floor(position.pos.x + 0.5)
    local tile_y = math.floor(position.pos.y + 0.5)
    if not get_tile_type(tile_x, tile_y) then
        engine.entities:destroy_entity(eid)
        return
    end

    local moving_to = state.path and state.path[state.path_i] or { x = tile_x, y = tile_y }

    local function find_new_target()
        verbose('  find_new_target()')
        state.path = nil

        local best_score = nil
        local potential_targets = {}

        traverse_breadth_first(moving_to, function (where, tile)
            if tile.type == TILE_CAP then
                potential_targets[#potential_targets + 1] = where
            end
            return true
        end)

        if #potential_targets > 0 then
            local roll = math.random(#potential_targets)
            state.target = potential_targets[roll]
            verbose('  target found (x = ' .. state.target.x .. ', y = ' .. state.target.y .. ')')
        end
    end

    if not state.target then
        verbose('no target, searching')
        find_new_target()
    else
        verbose('has target, checking for cap')
        local target_tile = get_tile(state.target.x, state.target.y)
        if not target_tile or target_tile.type ~= TILE_CAP then
            verbose('no cap, searching for new target')
            find_new_target()
        end
    end

    if state.target then
        verbose('has target')
        if not state.path or state.version ~= game_state.board_version then
            verbose('needs new path')
            local path = pathfind(moving_to, state.target)

            if path then
                verbose('path found (len = ' .. #path .. ')')
                state.path = path
                state.path_i = 1
                state.version = game_state.board_version
            else
                verbose('path not found')
                state.target = nil
                state.path = nil
            end
        end
    end

    pather.move(state, position, tile_x, tile_y)

    local cur_tile = get_tile(tile_x, tile_y)

    if cur_tile and cur_tile.type == TILE_CAP then
        verbose('on cap, working')
        state.timer = (state.timer or 0) + dt
        if state.timer >= 1 then
            verbose('cap proc')
            local high_priority = {}
            local low_priority = {}
            local last_resort = {}

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
                last_resort[#low_priority + 1] = TILE_NE
                last_resort[#low_priority + 1] = TILE_NW
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
                last_resort[#low_priority + 1] = TILE_SE
                last_resort[#low_priority + 1] = TILE_SW
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
                last_resort[#low_priority + 1] = TILE_NE
                last_resort[#low_priority + 1] = TILE_SE
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
                last_resort[#low_priority + 1] = TILE_NW
                last_resort[#low_priority + 1] = TILE_SW
            end

            local decision = nil

            if #high_priority > 0 then
                local roll = math.random(#high_priority)
                decision = high_priority[roll]
            elseif #low_priority > 0 then
                local roll = math.random(#low_priority)
                decision = low_priority[roll]
            elseif #last_resort > 0 then
                local roll = math.random(#last_resort)
                decision = last_resort[roll]
            else
                decision = TILE_CROSS
            end

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

            verbose('my purpose has been fulfilled')
            engine.entities:destroy_entity(eid)
        end
    else
        state.timer = 0
    end

    verbose('done.')

    verbose = function () end
end

function cell_blue.on_click(eid, pos, loc)
end

return cell_blue

