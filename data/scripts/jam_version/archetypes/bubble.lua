local engine = require('engine')

return function(init)
    init = init or {}

    local ent = engine.entities:create_entity()

    local position = component.position.new()
    position.pos.x = init.x or 0
    position.pos.y = init.y or 0
    position.z = 2

    local sprite = component.sprite.new()
    SPRITE_BUBBLE(sprite)
    sprite.speed = 3
    sprite.bounce = true

    local script = component.script.new()
    script.name = 'bubble'
    script.state = {}

    engine.entities:add_component(ent, position)
    engine.entities:add_component(ent, sprite)
    engine.entities:add_component(ent, script)

    return ent
end
