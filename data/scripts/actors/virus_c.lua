local engine = require('engine')
local visitor = require('visitor')
local pather = require('actors.pather')
local spawn_virus_c = require('archetypes.virus_c')
local rps_card = require('archetypes.rps_card')

local function verbose(s)
    print(s)
end

local virus_c = {}

function virus_c.update(eid, dt)
    verbose('virus_c')

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

        local target = nil
        local target_dist = nil

        verbose('    picking closest cell')
        visitor.visit({ component.tag_cell, component.position }, function (e, tag, cell_pos)
            verbose('    e '..e:get_index())

            local cell_x = math.floor(cell_pos.pos.x + 0.5)
            local cell_y = math.floor(cell_pos.pos.y + 0.5)

            local dist = math.abs(cell_x - tile_x) + math.abs(cell_y - tile_y)

            if not target or dist < target_dist then
                verbose('      setting as target')
                target = e
                target_dist = dist
                return
            end
        end)
        verbose('  algo done')

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

    verbose('searching')
    find_new_target()

    local final_dest = nil
    local move = true

    state.rps_timer = (state.rps_timer or 0) - dt

    if state.target then
        verbose('has target')
        local target_pos = engine.entities:get_component(state.target, component.position)

        final_dest = { x = target_pos.pos.x, y = target_pos.pos.x }

        if math.abs(target_pos.pos.x - position.pos.x) < 0.5 and 
            math.abs(target_pos.pos.y - position.pos.y) < 0.5 then
                move = false
                if not engine.entities:has_component(state.target, component.tag_cell_white) then
                    if state.convert_cooldown < 0 then
                        spawn_virus_c({ x = target_pos.pos.x, y = target_pos.pos.y })
                        engine.entities:destroy_entity(state.target)
                        play_sfx('virus', 1)
                        state.convert_cooldown = 1 + math.random()
                        return
                    end
                else
                    if state.rps_timer <= 0 then
                        verbose('rps time!')
                        local my_roll = math.random(3)
                        local their_roll = math.random(3)

                        verbose('me: ' .. my_roll .. ' them: ' .. their_roll)

                        rps_card({ x = position.pos.x, y = position.pos.y, rps = my_roll })
                        rps_card({ x = target_pos.pos.x, y = target_pos.pos.y, rps = their_roll })

                        if my_roll == 1 and their_roll == 3 or my_roll == 2 and their_roll == 1 or my_roll == 3 and their_roll == 2 then
                            verbose('i win')
                            engine.entities:destroy_entity(state.target)
                        elseif my_roll == their_roll then
                            verbose('draw')
                            state.rps_timer = 1
                        else
                            verbose('i lose')
                            unsub_death()
                            verbose('destroying self')
                            engine.entities:destroy_entity(eid)
                            verbose('destroying white')
                            engine.entities:destroy_entity(state.target)
                            return
                        end
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

    if move then pather.move(state, position, tile_x, tile_y, nil) end

    verbose('done.')

    verbose = function () end
end

function virus_c.on_click(eid, pos, loc)
end

function virus_c.death_notice(eid, dead)
    local script = engine.entities:get_component(eid, component.script)
    local state = script.state

    state.target = nil
    if state.path then
        state.path = { { x = state.path[state.path_i].x, y = state.path[state.path_i].y } }
        state.path_i = 1
    end
end

return virus_c

