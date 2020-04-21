local pan = {}

function pan.visit(dt)
    local spd = dt * 5

    if keys.left then game_state.pan.x = game_state.pan.x - spd end
    if keys.right then game_state.pan.x = game_state.pan.x + spd end
    if keys.down then game_state.pan.y = game_state.pan.y - spd end
    if keys.up then game_state.pan.y = game_state.pan.y + spd end

    if keys.action_pressed then
        game_state.pan.x = 0
        game_state.pan.y = 0
    end
end

return pan

