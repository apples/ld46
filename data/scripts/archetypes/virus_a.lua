if USE_JAM_VERSION then return require('jam_version.archetypes/virus_a') end

local engine = require('engine')

return function(init)
    init = init or {}

    local ent = engine.entities:create_entity()

    local position = component.position.new()
    position.pos.x = init.x or 0
    position.pos.y = init.y or 0
    position.z = 2

    local sprite = component.sprite.new()
    SPRITE_VIRUS_A(sprite)
    sprite.speed = 3
    sprite.bounce = true

    local script = component.script.new()
    script.name = 'virus_a'
    script.state = {}

    engine.entities:add_component(ent, component.tag_virus.new())
    engine.entities:add_component(ent, position)
    engine.entities:add_component(ent, sprite)
    engine.entities:add_component(ent, script)

    return ent
end
