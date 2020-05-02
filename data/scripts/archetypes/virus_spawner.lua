local engine = require('engine')

return function(init)
    init = init or {}

    local ent = engine.entities:create_entity()

    local script = component.script.new()
    script.name = 'virus_spawner'
    script.state = {
        weights = {
            a = 1,
            b = 0,
            c = -1,
            ab = -2,
            ac = -3,
            bc = -3,
            abc = -4,
        },
        current = {
            t = 0,
            duration = 1,
            virus = nil,
            difficulty = 0,
            curve = { 0 },
        },
        difficulty = { 0, 1, 1 },
        flipflop = 1,
    }

    engine.entities:add_component(ent, script)

    return ent
end
