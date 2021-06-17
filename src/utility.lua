function mapValue(value, value_min, value_max, target_min, target_max)
    return target_min + ((target_max - target_min) / (value_max - value_min)) * (value - value_min)
end

function mapIntegerColorToDecimal(red, green, blue)
    return {mapValue(red, 0, 255, 0, 1),
            mapValue(green, 0, 255, 0, 1),
            mapValue(blue, 0, 255, 0, 1)}
end