local obj = require 'core.obj'
local Sprite = require 'type.graphics.Sprite'

local ItemRegistry = obj.new('ItemRegistry', function(self, image, quantity, offset_x, offset_y, frame_width, frame_height, frame_spacing_x, frame_spacing_y)
    self.sprite = Sprite(image)
    self.sprite:loadFrames(
        quantity,
        offset_x, offset_y,
        frame_width, frame_height,
        frame_spacing_x, frame_spacing_y)
    self.registry = {}
    self.current_id = 1
    self.icon_table = {}
end)

function ItemRegistry:registerItemPrototype(frame_index, name, type, survival, abilities, uses)
    local ItemPrototype = obj.new('Item.'..name, function(self, registry)
        self.registry = registry
        self.prototype = {
            icon = frame_index,
            name = name,
            type = type,
            survival = survival,
            abilities = abilities,
            uses = uses
        }
    end))
    self.registry[self.current_id] = ItemPrototype
    self.current_id = self.current_id + 1
    return self.current_id - 1
end