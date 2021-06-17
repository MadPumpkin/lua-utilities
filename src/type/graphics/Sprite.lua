local obj = require 'core.obj'
local aabb = require 'core.aabb'
local Frame = require 'type.graphics.Frame'

local Sprite = obj.new('Sprite', function(self, image, frames)
    self.image = image
    self.image:setFilter('nearest','nearest')
    self.image_box = aabb.box(0, 0, self.image:getWidth(), self.image:getHeight())
    self.frames = frames or {}
end)

function Sprite:draw(frame_key, ...)
    self.frames[frame_key]:draw(...)
end

function Sprite:addFrame(frame)
    if obj.instance_of(frame, Frame) then
        self.frames[#self.frames+1] = frame
    end
end

function Sprite:loadFrames(quantity, offset_x, offset_y, frame_width, frame_height, frame_spacing_x, frame_spacing_y)
    local frames_per_row = (self.image:getWidth()-offset_x)/(frame_width+(frame_spacing_x and frame_spacing_x or 0))
    local frames_per_column = (self.image:getHeight()-offset_x)/(frame_height+(frame_spacing_x and frame_spacing_x or 0))
    local frames_in_region = frames_per_row * frames_per_column
    for i=0, math.min(frames_in_region, quantity and quantity or frames_in_region) do
        local row_number = math.floor(i/frames_per_row)
        self.frames[#self.frames+1] = Frame(
            self.image,
            offset_x + ((frame_spacing_x and frame_spacing_x or 0) * i) + i * frame_width,
            offset_y + ((frame_spacing_y and frame_spacing_y or 0) * row_number) + row_number * frame_height,
            frame_width,
            frame_height,
            self.image:getWidth(),
            self.image:getHeight())
    end
end

return Sprite
