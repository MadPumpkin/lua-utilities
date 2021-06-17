local obj = require 'obj'
local fn = require 'fn'

set = obj.new('_set')
set.elements = {}
set.typename_filter = nil


set.set_type_filter = function(self, type_name)
  if obj.type_exists(type_name) then
    self.typename_filter = type_name
  else
    error('set.set_type_filter(set, type_name) : type_name must be an existing type (from obj.type_list() )')
    return nil
  end
end

set.add = function(self, element, ignore_filter)
  local no_filter_exists = (not self.typename_filter)
  local element_matches_filter = (obj.is_object(element) and (obj.name(element) == self.typename_filter))
  if no_filter_exists or ignore_filter or element_matches_filter then
    self.elements[#self.elements+1] = element
    return #self.elements
  else
    error('set.add(set, element, ignore_filter) : element must be object type matching set.typename_filter, or ignore_filter must be true')
    return nil
  end
  error('set.add this should not be reached')
end

set.remove = function(self, handle)
  self.elements[handle] = nil
end

set.clean = function(self)
  self.elements = fn.clean(self.elements)
end

set.for_each = function(self, method, ...)
  for key, element in pairs(self.elements) do
    self.elements[key] = method(element, ...)
  end
end

set.dispatch = function(self, method, ...)
  for key, element in pairs(self.elements) do
    self.elements[key]:method(...)
  end
end

set.operate = function(self, method_name, ...)
  if fn[method_name] then
    self.elements = fn[method_name](self.elements, ...)
  else
    error('set.operate(set, method_name, ...) : method_name must be the name of a valid function within the fn module')
    return nil
  end
end

return set
