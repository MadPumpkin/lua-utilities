local fn = require 'core.fn'

obj = {}
if not obj.list then
  obj.list = {}
end
obj.__index = obj
obj.__next_obj_id = 0
obj.instance_meta = {
  __call = function(object, ...) return obj.instance(object, ...) end,
  __index = function(object, key) return obj.get_attribute(object, key) end,
  __newindex = function(object, key, value) return obj.set_attribute(object, key, value) end,
  __tostring = fn.to_string
  -- instance_of = function(object, type) return obj.is_instance(object, type) end,
  -- subclass = function(base, class_name) return obj.subclass(base, class_name) end
}
setmetatable(obj.instance_meta, obj)

function obj.__next_id()
  local id = obj.__next_obj_id
  obj.__next_obj_id = obj.__next_obj_id + 1
  return id
end

function obj.type(type_name)
  return obj.list[type_name]
end

function obj.type_exists(type_name)
  return obj.list[type_name] ~= nil
end

function obj.type_list()
  local result = {}
  for k,v in pairs(obj.list) do
    result[#result+1] = obj.list[k]
  end
  return result
end

function obj.is_object(table)
  if type(table) == 'table' then
    return table['__classtype'] ~= nil
  end
  return nil
end

function obj.assert_object(object)
  if obj.is_object(object) then
    return true
  else
    error('Error in obj.assert_object(object) : object was not of object type')
    return nil
  end
end

function obj.same_type(object, other)
  return (object.__classid == other.__classid)
end

function obj.is_instance(object)
  return obj.is_object(object) and object.__isinstance
end

function obj.is_prototype(object)
  return obj.is_object(object) and (object.__instanceid == -1)
end

function obj.instance_of(object, type)
  if obj.assert_object(object) and obj.assert_object(type) then
    local object_is_instance = obj.is_instance(object)
    local type_is_type = obj.is_object(type)
    if obj.same_type(object, type) then
      return object_is_instance and type_is_type
    end
  else
    error('Error in obj.instance_of(object, type) : Only objects can be instances of type objects')
    return nil
  end
end

function obj.new(class_name, constructor, ...)
  if class_name and type(class_name) == 'string' then
    if not obj.list[class_name] then
      local class = {
        __classid = obj.__next_id(),
        __instanceid = -1,
        __next_instance_id = 0,
        __classtype = true,
        __isinstance = false,
        class_name = class_name,
        attributes = {},
        superclasses = {},
        subclasses = {},
        constructor = nil,
        arguments = {...}
      }
      setmetatable(class, obj.instance_meta)
      if type(constructor) == 'function' then
        rawset(class, 'constructor', constructor)
      end
      obj.list[class.class_name] = class
      return class
    else
      error('Error in obj.new(class_name, ...) : obj.list already contains a class named "'..class_name..'"')
      return nil
    end
  else
    --[[TODO: Replace with Expect]]
    error('Error in obj.new(class_name, ...) : class_name invalid')
    return nil
  end
end

function obj.subclass(base, class_name, constructor, ...)
  if obj.is_object(base) then
    local type = obj.new(class_name,
                          function (instance, ...)
                            local base_result = nil
                            if type(base.constructor) == 'function' then
                              base_result = base.constructor()
                            end
                            return base_result, constructor(...)
                          end, ...)
    obj.add_superclass(type, base)
    return type
  else
    error('Error in obj.subclass(base, class_name) : base must be a type object')
    return nil
  end
end

function obj.descends_from(object, type)
  if obj.assert_object(object)
  and obj.assert_object(type) then
    local has_subclasses = (#type.subclasses > 0)
    if has_subclasses then
      -- If object is type, or object is among type's subclasses, true 
      if fn.satisfy(type.subclasses, obj.same_type, object)
      or obj.same_type(object, type) then
        return true
      else
        -- Otherwise recursively check object descends_from type's subclasses
        for k,v in pairs(type.subclasses) do
          if obj.descends_from(object, obj.type(v)) then
            return true
          end
        end
      end
    end
    return false
  end
  return nil
end

function obj.add_superclass(base, superclass)
  if obj.assert_object(base)
  and obj.assert_object(superclass) then
    if obj.same_type(base, superclass) then
      error("obj.add_superclass(base, superclass): base and superclass must be different types")
      return nil
    end
    if base.superclasses[superclass] then
      error("obj.add_superclass(base, superclass): superclass is an existing superclass of base")
    end
    if obj.descends_from(base, superclass)
    or obj.descends_from(superclass, base) then
      error("obj.add_superclass(base, superclass): neither base nor superclass may descend from one another")
      return nil
    else
      local base_super = rawget(base, 'superclasses')
      local super_subs = rawget(superclass, 'subclasses')
      rawset(base_super, #base_super+1, obj.name(superclass))
      rawset(super_subs, #super_subs+1, obj.name(base))
      return true
    end
  end
end

function obj.add_subclass(base, subclass)
  return obj.add_superclass(subclass, base)
end

function obj.identity(class)
  return class.__classid, class.__instanceid
end


function obj.name(class)
  return class.class_name
end

function obj.instance(class, ...)
  local instance = fn.clone(class)
  instance.arguments = fn.clone({...})
  instance.attributes = fn.clone(rawget(class, 'attributes'))
  instance.subclasses = fn.clone(rawget(class, 'subclasses'))
  instance.superclasses = fn.clone(rawget(class, 'superclasses'))
  instance.constructor = class.constructor
  instance.class_name = obj.name(class)
  instance.__classid, instance.__instanceid = obj.identity(class)
  instance.__classtype = true
  instance.__isinstance = true
  if class.__next_instance_id ~= nil then
    instance.__instanceid = rawget(class, '__next_instance_id')
    rawset(class, '__next_instance_id', rawget(class, '__next_instance_id') + 1)
  end
  instance.__next_instance_id = nil
  setmetatable(instance, obj.instance_meta)
  if instance.constructor ~= nil
  and type(instance.constructor) == 'function' then
    instance.constructor(instance, ...)
  end
  return instance
end

function obj.get_attribute(object, key)
  if obj.assert_object(object) then
    local attributes = rawget(object, 'attributes')
    local instance_attribute = rawget(attributes, key)
    if not instance_attribute then
      local superclasses = rawget(object, 'superclasses')
      for k,v in pairs(superclasses) do
        instance_attribute = obj.get_attribute(obj.list[v], key)
        if instance_attribute then
          return instance_attribute
        end
      end
    end
    return instance_attribute
  end
end

function obj.set_attribute(object, key, value)
  object.attributes[key] = value
  return object.attributes[key]
end

return obj
