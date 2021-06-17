local obj = require 'core.obj'

Clock = obj.new('Clock', function(self, interval, on_tick, on_finish, loop_on_finish, ...)
    self.interval = interval
    self.looping = loop_on_finish
    if on_finish == nil then return self end
    if type(on_tick) == 'function' then
        self.on_tick = function(self, dt, ...)
            return on_tick(self, dt, ...)
        end
    end
    if type(on_finish) == 'function' then
        self.on_finish = function(self, dt, ...)
            local result = on_finish(self, dt, ...)
            if self.looping then
                self:start()
            else
                self:pause()
            end
            return result
        end
    elseif on_finish ~= 'nil' then
        error('Clock(on_finish, ...) : on_finish was not a function')
    end
end)
Clock.paused = true
Clock.finished = false
Clock.elapsed = 0
Clock.interval = 0
Clock.overtime = 0

function Clock:loops()
    return self.looping
end

function Clock:start()
    self.elapsed = 0
    self.paused = false
    self.finished = false
end

function Clock:stop()
    self.elapsed = 0
    self.paused = true
    self.finished = false
end

function Clock:pause()
    self.paused = true
end

function Clock:unpause()
    self.paused = false
end

function Clock:tick(dt, ...)
    local result = nil
    if not self.paused then
        if self.elapsed < self.interval then
            self.elapsed = self.elapsed + dt
            if self.on_tick then
                result = self.on_tick(self, dt, ...)
            end
        else
            self.overtime = self.elapsed - self.interval
            self.finished = true
            result = self.on_finish(self, dt, ...)
            self.elapsed = self.overtime
        end
    end
    return result
end

return Clock