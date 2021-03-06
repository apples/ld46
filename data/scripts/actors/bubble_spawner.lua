if USE_JAM_VERSION then return require('jam_version.actors/bubble_spawner') end

local engine = require('engine')
local bubble = require('archetypes.bubble')
local spawner = require('actors.spawner')

local function verbose(s)
    print(s)
end

local bubble_spawner = {}

function bubble_spawner.update(eid, dt)
    verbose('bubble_spawner')

    local script = engine.entities:get_component(eid, component.script)
    local state = script.state

    local pow = math.sin(game_state.time) * 0.5 + 1;
    local rate = math.pow(1/512, pow)

    if not state.sfx and pow < 1 then
        play_sfx('breathe', 0.5)
        state.sfx = true
    end

    if pow > 1 then
        state.sfx = false
    end

    local spawnloc = spawner(rate, TILES_CORNERS)

    if spawnloc then
        bubble(spawnloc)
    end

    verbose('done.')

    verbose = function () end
end

function bubble_spawner.on_click(eid, pos, loc)
end

return bubble_spawner
