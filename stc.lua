local computer = require("computer")
local component = require("component")
local os = require("os")
local string = require("string")
local sides = require("sides")

local solar_tower = component.gt_machine
local transposer = component.transposer
local coolant_tank_side = sides.east
local input_side = sides.bottom

local heat_threshold = 50000

-- transfer coolant from tank to fluid input hatch
function transfer_coolant(amount)
    local status, xfer_amount = transposer.transferFluid(coolant_tank_side, input_side, amount)
end

-- example sensor information of solar tower
-- {"solartower.controller.tier.single", "Internal Heat Level: 100000", ...}
-- return heat
function parse_heat(sensor_info)
    return tonumber(string.sub(sensor_info[2], 22))
end

function main()
    while true do
        local status, ret = pcall(solar_tower.getSensorInformation)
        if not status then
            print("Unable to obtain solar tower sensor information.")
            goto continue
        end
        local heat = parse_heat(ret)

        -- coolant transfer when internal heat is higher than heat_threshold
        if heat > heat_threshold then
            transfer_coolant(heat - heat_threshold)
        end

        ::continue::
        -- sleep to reduce resource usage
        os.sleep(1)
    end
end

main()