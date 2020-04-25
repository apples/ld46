local engine = require('engine')
local visitor = require('visitor')

local scripting = {}

function scripting.visit(dt)
    visitor.visit(
        {component.script},
        function (eid, script)
            if script.next_tick == 0 then
                local script_impl = require('actors.' .. script.name)
                local success, result = pcall(script_impl.update, eid, dt)
                if not success then
                    print(result)
                    crash()
                end
            elseif script.next_tick > 0 then
                script.next_tick = script.next_tick - 1
            end
        end
    )
end

return scripting
