require 'utility'
local obj = require 'core.obj'
local aabb = require 'core.aabb'
local Sprite = require 'type.graphics.Sprite'
local Controller = require 'type.input.Controller'

local Player = obj.new('Player', function(self, image, frame_size, coordinate, actions, health, lamp_oil, sanity, inventory, controller_map)
    self.coordinate = {}
    self.coordinate.x = x
    self.coordinate.y = y
    self.emitted_light = 0
    self.colors = {
        blood_red = mapIntegerColorToDecimal(160, 31, 31),
        lamplight_yellow = mapIntegerColorToDecimal(220, 170, 85),
        horror_purple = mapIntegerColorToDecimal(95, 57, 136),
    }
    self.sprite = Sprite(image)
    self.frame_size = frame
    self.sprite_frame = 1
    self.coordinate = {
        x=0,
        y=0,
    }
    self.actions = 1
    self.inventory = {}
    self.equipment = {
    }
    self.survival = {
        health = 10,
        health_max = 10,
        sanity = 10,
        sanity_max = 10,
        lamp_oil = 10,
        lamp_oil_max = 10
    }
    self.skill = {
        hit = '1d6',
        critical = '1d6',
        guard = '1d6',
        evasion = '1d6',
        discovery = '1d6'
    }
    self.controller = Controller.new(controller_map)
    self.sprite:loadFrames(nil, 0, 0, frame_size[1], frame_size[2])
end)

function Player:drawSurvivalStats (x, y, stat_width, stat_height, stat_spacing)
    love.graphics.push()
    love.graphics.translate(x, y)
    local health_units = mapValue(self.survival.health,
                                    0, self.survival.health_max,
                                    0, stat_width)
    local lamp_oil_units = mapValue(self.survival.lamp_oil,
                                    0, self.survival.lamp_oil_max,
                                    0, stat_width)
    local sanity_units = mapValue(self.survival.sanity,
                                    0, self.survival.sanity_max,
                                    0, stat_width)
    local icon_scale = 0.4
    love.graphics.setColor(unpack(self.colors.blood_red))
    love.graphics.rectangle('fill', 0, 0, health_units, stat_height)
    world.icon_set:draw(2, -8, -1 + 0, 0, icon_scale, icon_scale)
    love.graphics.setColor(unpack(self.colors.lamplight_yellow))
    love.graphics.rectangle('fill', 0, stat_height+stat_spacing, lamp_oil_units, stat_height)
    world.icon_set:draw(3, -8, -1 + stat_height+stat_spacing, 0, icon_scale, icon_scale)
    love.graphics.setColor(unpack(self.colors.horror_purple))
    love.graphics.rectangle('fill', 0, (stat_height+stat_spacing)*2, sanity_units, stat_height)
    world.icon_set:draw(4, -8, -1 + (stat_height+stat_spacing)*2, 0, icon_scale, icon_scale)
    love.graphics.setColor(1.0, 1.0, 1.0)
    love.graphics.pop()
end

function Player:draw()
    local player_offset_x, player_offset_y = self.coordinate.x * 16, self.coordinate.y * 16
    
    love.graphics.push()
    love.graphics.translate(player_offset_x, player_offset_y)
    love.graphics.setColor(0.5 + self.emitted_light, 0.5 + self.emitted_light, 0.5 + self.emitted_light)
    self.sprite:draw(self.sprite_frame, -8, -24)
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1)
end

return Player