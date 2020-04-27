if USE_JAM_VERSION then return require('jam_version.actors/virus_a_spawner') end

local engine = require('engine')
local virus_a = require('archetypes.virus_a')
local spawner = require('actors.spawner')

local function verbose(s)
    print(s)
end

local virus_a_spawner = {}

function virus_a_spawner.update(eid, dt)
    verbose('virus_a_spawner')

    local spawnloc = spawner(1/1024 * get_spawn_rate(), {TILE_CAP})

    if spawnloc then
        virus_a(spawnloc)
    end

    verbose('done.')

    verbose = function () end
end

function virus_a_spawner.on_click(eid, pos, loc)
end

return virus_a_spawner
