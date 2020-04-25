local engine = require('engine')

return function(init)
    init = init or {}

    local ent = engine.entities:create_entity()

    local position = component.position.new()
    position.pos.x = init.x or 0
    position.pos.y = init.y or 0
    position.z = 2

    local sprite = component.sprite.new()
    SPRITE_CELL_WHITE(sprite)
    sprite.speed = 4
    sprite.bounce = true

    local script = component.script.new()
    script.name = 'cell_white'
    script.state = {}

    engine.entities:add_component(ent, component.tag_cell.new())
    engine.entities:add_component(ent, component.tag_cell_white.new())
    engine.entities:add_component(ent, position)
    engine.entities:add_component(ent, sprite)
    engine.entities:add_component(ent, script)

    return ent
end
