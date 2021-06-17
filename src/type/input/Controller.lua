local Controller = {}
Controller.__index = Controller

function Controller.new(controller_map)
    local controller = {
        controls = controller_map or {},
        keys_pressed = {},
        interval = 0.16,
        elapsed = 0,
        overtime = 0
    }
    setmetatable(controller, Controller)
    return controller
end

function Controller:addAction(name, keys, action)
    self.controls[#self.controls+1] = {name=name, keys=keys, action=action}
end

function Controller:getControlByName(name)
    for _,v in pairs(self.controls) do
        if v.name == name then
            return v
        end
    end
    return nil
end

function Controller:controlHasKey(name, key)
    for k,v in pairs(self:getControlByName(name).keys) do
        if v == key then return true end
    end
    return false
end

function Controller:executeControlAction(name, ...)
    local control = self:getControlByName(name)
    if nil ~= control
    and nil ~= control.action then
        return control.action(control, ...)
    end
    return nil
end

function Controller:hasKey(key)
    for _,v in pairs(self.controls) do
        if self:controlHasKey(v.name, key) then
            return true
        end
    end
    return false
end

function Controller:updateTick(dt, ...)
    if self.elapsed < self.interval then
        self.elapsed = self.elapsed + dt
    else
        self.overtime = self.elapsed - self.interval
        self.elapsed = self.overtime
        for k,v in pairs(self.keys_pressed) do
            if self:hasKey(v) then
                self:executeAllKeyActions(v, love.keyboard.getScancodeFromKey(v), true, ...)
            end
        end
    end
end

function Controller:executeAllKeyActions(key, scancode, isrepeat, ...)
    for _,v in pairs(self.controls) do
        if self:controlHasKey(v.name, key) then
            self:executeControlAction(v.name, ...)
        end
    end
end

function Controller:keypressed(key, scancode, isrepeat, ...)
    self:executeAllKeyActions(key, scancode, isrepeat, ...)
    self.keys_pressed[key] = key
    self.elapsed = 0
    self.overtime = 0
end

function Controller:keyreleased(key)
    self.keys_pressed[key] = nil
    self.elapsed = 0
    self.overtime = 0
end

function Controller:update(dt, ...)
    self:updateTick(dt, ...)
end

return Controller