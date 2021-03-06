if USE_JAM_VERSION then return require('jam_version.numeric') end

local numeric = {}

function numeric.round(x)
    return (x%1 >= 0.5 and (x >= 0 or x%1 ~= 0.5)) and math.ceil(x) or math.floor(x)
end

return numeric
