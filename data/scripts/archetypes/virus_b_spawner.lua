if USE_JAM_VERSION then return require('jam_version.archetypes/virus_b_spawner') end

local engine = require('engine')

return function(init)
    init = init or {}

    local ent = engine.entities:create_entity()

    local script = component.script.new()
    script.name = 'virus_b_spawner'
    script.state = {}

    engine.entities:add_component(ent, script)

    return ent
end
