local obj = require 'core.obj'

local Menu = obj.new('Menu',
  function (self,
            font,
            font_hover,
            color,
            color_hover,
            spacing)
    self.font = font 
    self.font_hover = font_hover
    self.color = color
    self.color_hover = color_hover
    self.spacing = spacing
  end)
Menu.buttons = {}

function Menu:addButton(button_text)
  self.buttons[#self.buttons+1] = {
    text = button_text,
    image = love.graphics.newText(self.font, button_text)
  }
end

function Menu:draw(x, y)
  for i,v in ipairs(self.buttons) do
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.draw (v.image, x, y+(i*self.spacing)-self.spacing)
  end
end

return Menu