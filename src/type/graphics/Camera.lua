local obj = require 'core.obj'
local aabb = require 'core.aabb'
require 'core.math'

local Camera = obj.new('Camera', function(self, x, y, w, h, zoom)
    self.active = false
    self.aabb = aabb.box(x, y, w, h)
    self.zoom = zoom
    self.target_zoom = zoom
    self.zoom_minimum = 0.4
    self.zoom_maximum = 10
    self.zoom_factor = 1
end)

function Camera:getViewRectangle()
    local top_left_x, top_left_y = self:transformPoint(x, y)
    local bottom_right_x, bottom_right_y = self:transformPoint(self.frame.width, self.frame.height)
    return {top_left_x, top_left_y, bottom_right_x, bottom_right_y}
  end

function Camera:zoomIn(x, y, scale, reset)
    if scale then
        if reset then
            self.zoom = 1
            self.target_zoom = 1
        end
        if math.sign(scale) > 0 then
            self.target_zoom = math.min(self.zoom_maximum, self.target_zoom + self.zoom_factor)
        elseif math.sign(scale) < 0 then
            self.target_zoom = math.max(self.zoom_minimum, self.target_zoom - self.zoom_factor)
        end
    else
        self.zoom = 0
        self.target_zoom = 0
    end
end

function Camera:drawBegin()
    if self.active then
        love.graphics.push()
        local half_width = love.graphics.getWidth()/2
        local half_height = love.graphics.getHeight()/2
        love.graphics.translate(half_width, half_height)
        love.graphics.translate(self.aabb.x, self.aabb.y)
        love.graphics.scale(self.zoom)
    end
end
  
function Camera:drawEnd()
    if self.active then
        love.graphics.pop()
    end
end

function Camera:draw(fn, ...)
    if type(fn) == 'function' then
        self:drawBegin()
            fn(...)
        self:drawEnd()
    end
end

function Camera:transformPoint(x, y)
    local scaled_x, scaled_y = (x * (1/self.zoom)), (y * (1/self.zoom))
    local transformed_x, transformed_y = scaled_x-self.aabb.x, scaled_y-self.aabb.y
    return transformed_x, transformed_y
end

function Camera:update(dt, x, y, interval)
    if self.active then
        self.zoom = math.lerp(self.zoom, self.target_zoom, dt * interval)
        self.aabb.x = math.lerp(self.aabb.x, -(x * self.target_zoom), dt * interval)
        self.aabb.y = math.lerp(self.aabb.y, -(y * self.target_zoom), dt * interval)
    end
end

return Camera