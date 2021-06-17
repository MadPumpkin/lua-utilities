local fn = {}
fn.table = {}
fn.__index = fn
fn.table.__index = fn

function tabulate(depth)
	return string.rep('\t', depth)
end

function fn.to_string(table, tabbing_depth, visited_list, recurse_depth, recurse_depth_max)
	local visited_tables = visited_list or {}
	local tabdepth = tabbing_depth or 0
	local result = ''
	if nil == recurse_depth then
		recurse_depth = 0
	end
	if nil == recurse_depth_max then
		recurse_depth_max = 100
	end
	if recurse_depth < recurse_depth_max then
		if table == nil then
			result = result..'nil'
		elseif type(table) == 'table' then
			if not fn.satisfy(visited_tables, function(t) return t == table end) then
				for key, value in pairs(table) do
					if type(value) == 'table' then
						-- Nested table, then add it to visited table list
						if not fn.satisfy(visited_tables, function(v) return v == value end) then
							-- Begin table_string construction
							local table_string = tostring(key)..': ['..tostring(table)..']'..' {'
							local value_string = fn.to_string(value, tabdepth+1, visited_tables, recurse_depth+1, recurse_depth_max)
							if string.len(value_string) > 0 then
								table_string = tabulate(tabdepth)..table_string..'\n'
							end
							table_string = table_string..value_string
							table_string = table_string..tabulate(tabdepth)..'}\n'
							-- End table_string construction
							-- Append Table
							result = result..table_string
							visited_tables[#visited_tables+1] = value
						else
							result = result..tostring(value)..'\n'
						end
					else
						-- Nested, non-table key
						result = result..tabulate(tabdepth)..fn.to_string(key, tabdepth+1, visited_tables, recurse_depth+1, recurse_depth_max)
						-- Nested, non-table value
						result = result..' : '..fn.to_string(rawget(table, key), tabdepth+1, visited_tables, recurse_depth+1, recurse_depth_max)..'\n'
					end
				end
				visited_tables[#visited_tables+1] = table
			end
		elseif type(table) == 'function' then
			result = result..'['..tostring(table)..']'..' `'
			local fn_info = debug.getinfo(table, 'nSluflL')
			fn_info.func = '['..tostring(fn_info.func)..']'
			local fn_string = fn.to_string(fn_info, tabdepth, visited_tables, recurse_depth+1, recurse_depth_max)
			if string.len(fn_string) > 0
			and tabdepth+1 > 0 then
				result = result..'\n'
			end
			result = result..fn_string..'`'
		elseif type(table) == 'string' then
			result = result..table
		else
			result = result..tostring(table)
		end
	end
	return result
end

-- Target table and it's elements are cloned
function fn.shallow_clone(set)
	local clone
	if type(set) == 'table' then
		clone = {}
		for k,v in pairs(set) do
			clone[k] = v
		end
	else
		clone = set
	end
	return clone
end

-- Target table is cloned recursively including the metatable
function fn.deep_clone(set, clone_meta)
	local clone
	if type(set) == 'table' then
		clone = {}
		for k, v in next, set, nil do
			clone[fn.deep_clone(k)] = fn.deep_clone(v)
		end
		if clone_meta then
			setmetatable(clone, fn.deep_clone(getmetatable(set)))
		end
	else
		clone = set
	end
	return clone
end

function fn.clone(set)
	return fn.deep_clone(set, true)
end

function fn.join(set, other, hard_join, ...)
	local arguments = ...
	for k, v in pairs(other) do
		-- Hard join will add duplicates but replace any duplicate key
		-- Soft join will not replace duplicates, the value in 'set' will be used
		if hard_join or ((not hard_join) and not set[k]) then
			set[k] = v
		end
	end
	if arguments ~= nil then
		for i=1,#arguments do
			set = fn.join(set, arguments[i], hard_join)
		end
	end
	return set
end

function fn.reverse(set)
	local left, right = 1, #set
	while left < right do
		set[left], set[right] = set[right], set[left]
		left = left + 1
		right = right - 1
	end
end

function fn.invert(set)
	for k,v in pairs(set) do
		set[v] = k
		set[k] = nil
	end
	return set
end

function fn.find_key_value_pair(set, value)
	for k,v in pairs(set) do
		if set[k] == value then
			return k, set[k]
		end
	end
	return nil
end

function fn.table.keys_with_value(set, value)
	local result = {}
	for k,v in pairs(set) do
		if set[k] == value then
			result[#result+1] = k
		end
	end
	return result
end

function fn.table.keys(set)
	local result = {}
	for k,v in pairs(set) do
		result[#result+1] = k
	end
	return result
end

function fn.table.values(set)
	local result = {}
	for k,v in pairs(set) do
		result[#result+1] = v
	end
	return result
end

function fn.table.transpose_values(set, ...)
	local inverted = fn.invert(fn.clone(set))
	return fn.map(inverted, function(element, ...)
								return inverted[element]
							end)
end

function fn.table.transpose_keys(set, ...)
	local clone = fn.clone(set)
	return fn.meta_map(clone,
							function(set, key, value, ...)
								return set[key]
							end)
end

function fn.meta_map(set, operator, ...)
	for key, value in pairs(set) do
		set[key] = operator(set, key, value, ...)
	end
	return set
end

function fn.map(set, operator, ...)
	for key, value in pairs(set) do
		set[key] = operator(value, ...)
	end
	return set
end

function fn.filter(set, operator, ...)
	for key, value in pairs(set) do
		if operator(value, ...) then
			set[key] = value
		else
			set[key] = nil
		end
	end
	return set
end

-- Whether set has a value satisfying 'conditional(element, ...)'
function fn.satisfy(set, conditional, ...)
	for key, element in pairs(set) do
		if conditional(element, ...) then
			return true
		end
	end
	return false
end

-- foldl left -> right
function fn.fold_left(set, operator, initial_value, ...)
	local value = initial_value or 0
	for _, key in pairs(set) do
		value = operator(value, key, ...)
	end
	return value
end


-- foldr left <- right
function fn.fold_right(set, operator, initial_value, ...)
	local value = initial_value or 0
	for i=#set, 1, -1 do
		value = operator(value, set[i], ...)
	end
	return value
end

function fn.accumulate(set, operator, ...)
	return fn.fold_left(set, operator, 0, ...)
end

function fn.reduce(set, operator, ...)
	return fn.fold_right(set, operator, 0, ...)
end


--[[ Save the generated functions from the below functions to reuse, these are all slow
]]
function fn.curry(f, g, ...)
	if select('#', ...) > 0 then
		local arguments = {...}
		return (function()
					return f(g(unpack(arguments)))
				end)
	else
		return (function()
					return f(g())
				end)
	end
end

function fn.bind_first(operator, first, ...)
	if select('#', ...) > 0 then
		local arguments = {...}
		return (function(second)
					return operator(first, second, unpack(arguments))
				end)
	else
		return (function(second)
					return operator(first, second)
				end)
	end
end

function fn.bind_second(operator, second, ...)
	if select('#', ...) > 0 then
		local arguments = {...}
		return (function(first)
					return operator(first, second, unpack(arguments))
				end)
	else
		return (function(first)
					return operator(first, second)
				end)
	end
end

function fn.replicate(operator, ...)
	local arguments = {...}
	return (function()
				return operator(unpack(arguments))
			end)
end

function fn.clean(set)
	return fn.filter(set, fn.bind_first(fn.contains_value, set))
end

return fn
