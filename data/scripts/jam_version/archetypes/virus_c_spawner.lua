local engine = require('engine')

return function(init)
    init = init or {}

    local ent = engine.entities:create_entity()

    local script = component.script.new()
    script.name = 'virus_c_spawner'
    script.state = {}

    engine.entities:add_component(ent, script)

    return ent
end
