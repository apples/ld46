if USE_JAM_VERSION then return require('jam_version.actors/cell_white') end

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

    local function unsub_death()
        if state.target then
            if engine.entities:has_component(state.target, component.death_notifier) then
                verbose('  unsub death_notifier')
                local dn = engine.entities:get_component(state.target, component.death_notifier)
                for i,v in ipairs(dn.ents) do
                    if v:get_index() == eid:get_index() then
                        dn.ents:erase(i)
                        break
                    end
                end
            end
        end
    end

    local function find_new_target()
        verbose('  find_new_target()')

        local picker = es_jump_sampler.new(1)

        verbose('    picking random virus')
        visitor.visit({ component.tag_virus, component.position }, function (e, tag, pos)
            local dx = pos.pos.x - position.pos.x
            local dy = pos.pos.y - position.pos.y
            local dist = math.sqrt(dx*dx + dy*dy)
            picker:add(e, 1/dist)
        end)

        local results = picker:get_results()
        local target = #results > 0 and results[1]

        if target then
            if state.target and target:get_index() ~= state.target:get_index() then unsub_death() end

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

    local move = true

    if state.target then
        verbose('has target')
        local target_pos = engine.entities:get_component(state.target, component.position)

        if math.abs(target_pos.pos.x - position.pos.x) < 0.5 and 
            math.abs(target_pos.pos.y - position.pos.y) < 0.5 then
                move = false
                if not engine.entities:has_component(state.target, component.tag_virus_c) then
                    if engine.entities:has_component(state.target, component.tag_virus_a) then
                        state.health = state.health - 1
                    elseif engine.entities:has_component(state.target, component.tag_virus_b) then
                        state.health = state.health - 5
                    end

                    engine.entities:destroy_entity(state.target)

                    if state.health <= 0 then
                        engine.entities:destroy_entity(eid)
                        return
                    end
                end
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

    if move then pather.move(state, position, tile_x, tile_y) end

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

