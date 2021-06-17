local generator = {
    seed = math.randomseed(os.time()),
    random = math.random,
    next = function(self, precision, ...)
        if 0 == precision then
            return self.random(...)
        else
            return tonumber(string.format(string.format('%%0.%sf', precision), self.random(...)))
        end
    end,
    range = function(self, quantity, precision, ...)
        local numbers = {}
        for i=0,quantity-1 do
            numbers[#numbers+1] = self:next(precision, ...)
        end
        return numbers
    end
}

return generator