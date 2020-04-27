if USE_JAM_VERSION then return require('jam_version.actors/virus_b_spawner') end

local engine = require('engine')
local virus_b = require('archetypes.virus_b')
local spawner = require('actors.spawner')

local function verbose(s)
    print(s)
end

local virus_b_spawner = {}

function virus_b_spawner.update(eid, dt)
    verbose('virus_b_spawner')

    local pow = math.sin(game_state.time / 3) * 0.5 + 1.4;
    local rate = math.pow(1/1024, pow)

    local spawnloc = spawner(rate * get_spawn_rate(), TILES_CORNERS)

    if spawnloc then
        if math.random(spawnloc.depth) == 1 then
            virus_b(spawnloc)
        end
    end

    verbose('done.')

    verbose = function () end
end

function virus_b_spawner.on_click(eid, pos, loc)
end

return virus_b_spawner
