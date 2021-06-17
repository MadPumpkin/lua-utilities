local obj = require 'core.obj'

local Frame = obj.new('Frame', function(self, image, x, y, w, h)
    self.image = image
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.quad = love.graphics.newQuad(x, y, w, h, image:getWidth(), image:getHeight())
end)

function Frame:draw(x, y, r, sx, sx, ox, oy, kx, ky)
    love.graphics.push()
    love.graphics.translate(x or 0, y or 0)
    love.graphics.scale(sx or 1, sx or 1)
    love.graphics.rotate(r or 0)
    love.graphics.draw(self.image, self.quad, 0, 0, 0, ox, oy, kx, ky)
    love.graphics.pop()
end

return Frame