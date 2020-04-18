local engine = require('engine')

return function(init)
    init = init or {}

    local ent = engine.entities:create_entity()

    local position = component.position.new()
    position.pos.x = init.x or 0
    position.pos.y = init.y or 0

    local sprite = component.sprite.new()
    sprite.frames = SPRITE_HEART
    sprite.speed = 3
    sprite.bounce = true

    engine.entities:add_component(ent, component.tag_heart.new())
    engine.entities:add_component(ent, position)
    engine.entities:add_component(ent, sprite)

    return ent
end
