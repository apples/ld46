if USE_JAM_VERSION then return require('jam_version.actors/spawner') end


return function(rate, is_valid)
    local opens = {}

    traverse_breadth_first({ x = 0, y = 0 }, function (where, tile)
        if is_valid(where, tile) then
            opens[#opens + 1] = where
        end
        return true
    end)

    if #opens > 0 then
        for i=1,#opens do
            if math.random() < rate then
                local pick = opens[math.random(#opens)]
                return pick
            end
        end
    end
end
