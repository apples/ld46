local engine = require('engine')

return function(init)
    init = init or {}

    local ent = engine.entities:create_entity()

    local position = component.position.new()
    position.pos.x = init.x or 0
    position.pos.y = init.y or 0
    position.z = 3

    local sprite = component.sprite.new()
    sprite.frames:add(component.rowcol.new(10, (init.rps or 1) - 1))
    sprite.speed = 3
    sprite.bounce = true

    local script = component.script.new()
    script.name = 'rps_card'
    script.state = {
        timer = 0.5
    }

    engine.entities:add_component(ent, position)
    engine.entities:add_component(ent, sprite)
    engine.entities:add_component(ent, script)

    return ent
end
