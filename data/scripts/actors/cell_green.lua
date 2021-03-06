if USE_JAM_VERSION then return require('jam_version.actors/cell_green') end

local engine = require('engine')
local pather = require('actors.pather')

local function verbose(s)
    print(s)
end

local cell_green = {}

function cell_green.update(eid, dt)
    verbose('cell_green')

    local position = engine.entities:get_component(eid, component.position)
    local script = engine.entities:get_component(eid, component.script)
    local state = script.state

    local tile_x = math.floor(position.pos.x + 0.5)
    local tile_y = math.floor(position.pos.y + 0.5)
    if not get_tile_type(tile_x, tile_y) then
        engine.entities:destroy_entity(eid)
        return
    end

    local function is_good_target(where, tile)
        local N = get_tile_type(where.x, where.y + 1)
        local S = get_tile_type(where.x, where.y - 1)
        local E = get_tile_type(where.x + 1, where.y)
        local W = get_tile_type(where.x - 1, where.y)

        local N_connected = (N == TILE_SE or N == TILE_SW or N == TILE_CROSS)
        local S_connected = (S == TILE_NE or S == TILE_NW or S == TILE_CROSS)
        local E_connected = (E == TILE_NW or E == TILE_SW or E == TILE_CROSS)
        local W_connected = (W == TILE_NE or W == TILE_SE or W == TILE_CROSS)

        local blocked =
            tile.type == TILE_NE and (S_connected or W_connected) or
            tile.type == TILE_SE and (N_connected or W_connected) or
            tile.type == TILE_NW and (S_connected or E_connected) or
            tile.type == TILE_SW and (N_connected or E_connected)

        return blocked
    end

    local function is_okay_target(where, tile)
        return tile.type == TILE_NE or tile.type == TILE_SE or tile.type == TILE_NW or tile.type == TILE_SW
    end

    local moving_to = state.path and state.path[state.path_i] or { x = tile_x, y = tile_y }

    local function find_new_target()
        verbose('  find_new_target()')
        state.path = nil

        local picker = es_jump_sampler.new(1)

        traverse_breadth_first(moving_to, function (where, tile)
            local score = math.abs(where.x - tile_x) + math.abs(where.y - tile_y)
            if is_good_target(where, tile) then
                picker:add(where, 10 / score)
            elseif is_okay_target(where, tile) then
                picker:add(where, 1 / score)
            end
            return true
        end)

        local results = picker:get_results()

        if #results > 0 then
            state.target = results[1]
            verbose('  target found (x = ' .. state.target.x .. ', y = ' .. state.target.y .. ')')
        end
    end

    if not state.target then
        verbose('no target, searching')
        find_new_target()
    else
        verbose('has target, checking for feasibility')
        local target_tile = get_tile(state.target.x, state.target.y)
        if not target_tile or not is_okay_target(state.target, target_tile) then
            verbose('no good, searching for new target')
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

    if state.target and tile_x == state.target.x and tile_y == state.target.y then
        local cur_tile = get_tile(tile_x, tile_y)
        verbose('on target, working')
        state.timer = (state.timer or 0) + dt
        if state.timer >= 1 then
            verbose('cross proc')
            local high_priority = {}
            local low_priority = {}
            local last_resort = {}

            local N = get_tile_type(tile_x, tile_y + 1)
            local S = get_tile_type(tile_x, tile_y - 1)
            local E = get_tile_type(tile_x + 1, tile_y)
            local W = get_tile_type(tile_x - 1, tile_y)

            set_tile(tile_x, tile_y, TILE_CROSS)

            if not N then
                set_tile(tile_x, tile_y + 1, TILE_CAP)
            end
            if not S then
                set_tile(tile_x, tile_y - 1, TILE_CAP)
            end
            if not E then
                set_tile(tile_x + 1, tile_y, TILE_CAP)
            end
            if not W then
                set_tile(tile_x - 1, tile_y, TILE_CAP)
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

function cell_green.on_click(eid, pos, loc)
end

return cell_green

