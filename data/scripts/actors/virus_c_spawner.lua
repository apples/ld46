if USE_JAM_VERSION then return require('jam_version.actors/virus_c_spawner') end

local engine = require('engine')
local virus_c = require('archetypes.virus_c')
local spawner = require('actors.spawner')

local function verbose(s)
    print(s)
end

local virus_c_spawner = {}

function virus_c_spawner.update(eid, dt)
    verbose('virus_c_spawner')

    local spawnloc = spawner(1/2048 * get_spawn_rate(), {TILE_CAP}, { mindepth = 8 })

    if spawnloc then
        virus_c(spawnloc)
    end

    verbose('done.')

    verbose = function () end
end

function virus_c_spawner.on_click(eid, pos, loc)
end

return virus_c_spawner
