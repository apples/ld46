local engine = require('engine')
local visitor = require('visitor')
local pather = require('actors.pather')

local function verbose(s)
    print(s)
end

local cell_white = {}

function cell_white.update(eid, dt)
    verbose('cell_white')

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

        local target = nil
        local skips = 1
        local weight = math.random()

        local function calc_skips()
            return math.floor(math.log(math.random())/math.log(1-weight))
        end
        
        verbose('    picking random virus')
        visitor.visit({ component.tag_virus }, function (e, tag)
            verbose('    e '..e:get_index())
            if not target then
                verbose('      setting as default target')
                target = e
                skips = calc_skips()
                return
            end

            if skips > 0 then
                skips = skips - 1
                verbose('    skipping '..e:get_index())
            else
                verbose('    rolling '..e:get_index())
                target = e
                weight = weight * math.random()
                skips = calc_skips()
            end
        end)
        verbose('  algo done')

        if target then
            state.target = target
            verbose('  target found: ' .. (target and target:get_index() or 'nil'))
            verbose(component.death_notifier)

            if not engine.entities:has_component(target, component.death_notifier) then
                verbose('  adding death_notifier')
                engine.entities:add_component(target, component.death_notifier.new())
            end

            verbose('  subscribing to death')
            local dn = engine.entities:get_component(target, component.death_notifier)
            dn.ents:add(eid)
        end

        verbose('  target search done')
    end

    if not state.target then
        verbose('no target, searching')
        find_new_target()
    end

    if state.target then
        verbose('has target')
        local target_pos = engine.entities:get_component(state.target, component.position)

        if math.abs(target_pos.pos.x - position.pos.x) < 0.5 and 
            math.abs(target_pos.pos.y - position.pos.y) < 0.5 then
                engine.entities:destroy_entity(state.target)
                engine.entities:destroy_entity(eid)
                return
        end

        local target_loc = { x = math.floor(target_pos.pos.x + 0.5), y = math.floor(target_pos.pos.y + 0.5)}

        if not state.last_target_loc then
            state.last_target_loc = target_loc
        end

        if not state.path or state.version ~= game_state.board_version or
            state.last_target_loc.x ~= target_loc.x or state.last_target_loc.y ~= target_loc.y then
            verbose('needs new path')

            state.last_target_loc = target_loc

            local path = pathfind(moving_to, target_loc, true)

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

    verbose('done.')

    verbose = function () end
end

function cell_white.on_click(eid, pos, loc)
end

function cell_white.death_notice(eid, dead)
    local script = engine.entities:get_component(eid, component.script)
    local state = script.state

    state.target = nil
    if state.path then
        state.path = { { x = state.path[state.path_i].x, y = state.path[state.path_i].y } }
        state.path_i = 1
    end
end

return cell_white

