if USE_JAM_VERSION then return require('jam_version.archetypes/heart') end

local engine = require('engine')

return function(init)
    init = init or {}

    local ent = engine.entities:create_entity()

    local position = component.position.new()
    position.pos.x = init.x or 0
    position.pos.y = init.y or 0
    position.z = 1

    local sprite = component.sprite.new()
    SPRITE_HEART(sprite)
    sprite.speed = 3
    sprite.bounce = true

    local script = component.script.new()
    script.name = 'heart'
    script.state = {
        decay_timer = 0
    }

    engine.entities:add_component(ent, component.tag_heart.new())
    engine.entities:add_component(ent, position)
    engine.entities:add_component(ent, sprite)
    engine.entities:add_component(ent, script)

    return ent
end
