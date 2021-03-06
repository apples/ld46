if USE_JAM_VERSION then return require('jam_version.systems/init') end

local scripting = require('systems.scripting')
local velocity = require('systems.velocity')
local physics = require('systems.physics')
local animation = require('systems.animation')
local pan = require('systems.pan')
local hm = require('systems.health_manager')
local dm = require('systems.difficulty_manager')
local mm = require('systems.mitosis_manager')

local systems = {}

local function run(name, sys, delta)
    trace_push('(SYSTEM) '..name)
    sys.visit(delta)
    trace_pop('(SYSTEM) '..name)
end

function systems.visit(delta)
    run('scripting', scripting, delta)
    run('velocity', velocity, delta)
    run('physics', physics, delta)
    run('animation', animation, delta)
    run('pan', pan, delta)
    run('hm', hm, delta)
    run('dm', dm, delta)
    run('mm', mm, delta)
end

return systems

