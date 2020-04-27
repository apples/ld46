
local random_picker = {}

random_picker.__index = random_picker

function random_picker.new()
    local o = {
        skips = 0,
        weight = 1,
        result = {},
        resultc = 0,
    }
    setmetatable(o, random_picker)
    return o
end

function random_picker:__call(...)
    if self.skips > 0 then
        self.skips = self.skips - 1
    else
        self.result = { ... }
        self.resultc = select('#', ...)
        self.weight = self.weight * math.random()
        self.skips = math.floor(math.log(math.random())/math.log(1-self.weight))
    end
end

function random_picker:unpack(exec)
    exec((unpack or table.unpack)(self.result, 1, self.resultc))
end

return random_picker
