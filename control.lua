require("util/class")
require('scripts/pollution-calc')

local pCalc = PollutionCalc()

script.on_event(defines.events.on_player_selected_area, function(event)
    pCalc:OnSelect(event, false);
end)

script.on_event(defines.events.on_player_alt_selected_area, function(event)
    pCalc:OnSelect(event, true)
end)