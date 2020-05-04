local mitosis_manager = {}

function mitosis_manager.visit(dt)
    if game_state.mitosis < 0 then
        game_state.mitosis = 0
    end

    game_state.mitosis_buildup = game_state.mitosis_buildup + dt

    if game_state.mitosis_buildup >= 1 then
        game_state.mitosis = game_state.mitosis + 1
        game_state.mitosis_buildup = game_state.mitosis_buildup - 1
    end
end

return mitosis_manager
