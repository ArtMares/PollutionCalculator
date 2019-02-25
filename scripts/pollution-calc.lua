function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

PollutionCalc = class(function(self)
    self.name = "Pollution calculator"
end)

function PollutionCalc:HumanView(value) 
    local prefix = {'', 'k', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y'}
    local index = 1
    for i = 1, #prefix do
        if value > 999 then
            value = value / 1000
            index = index + 1
        end
    end
    return {'', round(value, 2), {prefix[index]}, {'W'}}
end

function PollutionCalc:CalcEmission(entities, area)
    local count, pollution, energy, fuel = 0, 0, 0, 0
    for _, entity in ipairs(entities) do
        if entity.prototype.max_energy_usage ~= nil then
            local inChunk = true
            if area ~= nil and (entity.position.x < area[1][1] or entity.position.x >= area[2][1] or entity.position.y < area[1][2] or entity.position.y >= area[2][2]) then
                inChunk = false
            end
            if inChunk == true then
                local realEnergy, realFuel, emissions = 0, 0, 0, 0
                -- get module effects
                local moduleInvetory = entity.get_module_inventory() or {}
                local consumptionMult, pollutionMult = 1, 1
                for i = 1, #moduleInvetory do
                    if moduleInvetory[i].is_module then
                        if moduleInvetory[i].prototype.module_effects.consumption ~= nil and moduleInvetory[i].prototype.module_effects.consumption.bonus ~= nil then
                            consumptionMult = consumptionMult + moduleInvetory[i].prototype.module_effects.consumption.bonus
                            if consumptionMult < 0.2 then
                                consumptionMult = 0.2
                            end
                        end
                        if moduleInvetory[i].prototype.module_effects.pollution ~= nil and moduleInvetory[i].prototype.module_effects.pollution.bonus ~= nil then
                            pollutionMult = pollutionMult + moduleInvetory[i].prototype.module_effects.pollution.bonus
                        end
                    end
                end
                if entity.prototype.burner_prototype ~= nil then
                    count = count + 1
                    local maxEnergy = entity.prototype.max_energy_usage * consumptionMult
                    realFuel = maxEnergy / entity.prototype.burner_prototype.effectivity * 60
                    emissions = entity.prototype.burner_prototype.emissions * pollutionMult * maxEnergy * 60
                elseif entity.prototype.electric_energy_source_prototype ~= nil then
                    count = count + 1
                    local maxEnergy = entity.prototype.max_energy_usage * consumptionMult
                    realEnergy = (entity.prototype.electric_energy_source_prototype.drain + maxEnergy) * 60
                    emissions = entity.prototype.electric_energy_source_prototype.emissions * pollutionMult * maxEnergy * 60
                end
                pollution = pollution + emissions
                energy = energy + realEnergy
                fuel = fuel + realFuel
            end
        end
    end
    return {count, round(pollution, 2), self:HumanView(energy), self:HumanView(fuel)}
end

function PollutionCalc:OnSelect(event, altMode)
    if event.item == "pollution-calc" and event.player_index ~= nil then
        if (altMode == true and game.players[event.player_index].mod_settings["pollution-calc-toggle-shift"].value == false) or 
           (#event.entities < 2 and game.players[event.player_index].mod_settings["pollution-calc-toggle-shift"].value and altMode == false) then
            local x, y = event.area.left_top.x, event.area.left_top.y
            local x1, y1 = math.floor(x / 32) * 32, math.floor(y / 32) * 32
            local x2, y2 = math.ceil(x / 32) * 32, math.ceil(y / 32) * 32
            local area = {{x1, y1}, {x2, y2}}
            -- local entities = game.players[event.player_index].surface.find_entities(area)
            local entities = game.players[event.player_index].surface.find_entities_filtered{area = area, force = game.players[event.player_index].force}
            local output = self:CalcEmission(entities, area)
            game.players[event.player_index].print{"pollution-calc-output", output[1], output[2], output[3], output[4]}
        else
            local output = self:CalcEmission(event.entities)
            game.players[event.player_index].print{"pollution-calc-output", output[1], output[2], output[3], output[4]}
        end
    end
end