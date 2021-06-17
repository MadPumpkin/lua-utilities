require 'math'

grammar = {}
grammar.__index = grammar
grammar.properties = {
  'expands',
  'narrows',
  'translates'
}

function grammar.g()
  local grammar = {
    symbols = {},
    productions = {},
    stop_condition = function() return true end
  }
  setmetatable(grammar, self)
  self.__index = self

  return grammar
end

function grammar:valid(symbol)
  if self.symbols[symbol] ~= nil then
    return true
  else
    error("Invalid symbol in grammar:valid(symbol) with 'symbol' " .. symbol)
  end
end

function grammar:terminal(symbol)
  if self:valid(symbol) then
    return #self.productions[symbol] < 1
  end
end

function grammar:has_symbol(symbol)
  return self.symbols[symbol] ~= nil
end

function grammar:has_productions(symbol)
  if self:valid(symbol) then
    return #self.productions[symbol] > 0
  end
end

function grammar:set_stop_condition(stop_condition)
  self.stop_condition = stop_condition
end

function grammar:set_term(symbol, productions)
  self.symbols[symbol] = symbol
  self.productions[symbol] = productions
end

function grammar:add_symbol(symbol_string, ...)
  assert(type(symbol_string) == "string" or type(symbol_string) == "table")
  if 'table' == type(symbol_string) then
    for i=1, #symbol_string do
      self:add_symbol(symbol_string[i])
    end
  elseif 'string' == type(symbol_string) then
    local symbol_length = string.len(symbol_string)
    if symbol_length > 1 then
      for i=1, symbol_length do
        self:set_term(symbol_string:sub(i, i), {})
      end
    elseif symbol_length == 1 then
      self:set_term(symbol_string, {})
      if args > 0 then
        self:add_symbol(unpack(args))
      end
    end
  end
end

function grammar:add_production(symbol, production)
  assert(type(symbol) == "string")
  assert(type(production) == "string")
  if self:valid(symbol) then
    self.productions[symbol][#self.productions[symbol]+1] = production
  end
end

function grammar:production_for(symbol, index)
  if self:terminal(symbol) then return symbol end
  if self:has_productions(symbol)
  and math.range(index, 1, #self.productions[symbol]) then
    return self.productions[symbol][index]
  else
    error("In grammar:production_for(symbol, index) index must be an integer in the range 1 to the num. of symbol productions")
  end
  return ''
end

function grammar:production_property(symbol, index)
  if string.len(self:production_for(symbol, index)) > string.len(symbol) then
    return 'expands'
  elseif string.len(self:production_for(symbol, index)) < string.len(symbol) then
    return 'narrows'
  end
  return 'translates'
end

function grammar:symbol_has_property(property, symbol)
  if grammar.properties[property] ~= nil then
    for i=1, #self.productions[symbol] do
      if property == self:production_property(symbol, i) then
        return true
      end
    end
  else
    error("grammar:symbol_has_property(symbol, property) expects a property from grammar.properties, one of: 'expands', 'narrows', 'translates'")
  end
  return false
end

function grammar:next_production(input_string)
  local result_string = ''
  for i = 1, #input_string do
    local c = input_string:sub(i, i)
    result_string = result_string .. self:production_for(c))
  end
  return result_string
end

function grammar:nth_production(n, input_string)
  local result_string = input_string
  for i=1,n do
    result_string = self:next_production(result_string)
  end
  return result_string
end

function grammar:stripNonTerminalSymbols(input_string)
  local result_string = ''
  for i = 1, #input_string do
    local c = input_string:sub(i, i)
    if self:terminal(c) then
      result_string = result_string .. c
    end
  end
  return result_string
end

function grammar:generate_with_symbol_productions(symbol, input_string)
  local result_string = ''
  for i = 1, #input_string do
    local c = input_string:sub(i, i)
    if symbol == c then
      result_string = result_string .. self:getProductionFor(c)
    else
      result_string = result_string .. c
    end
  end
  return result_string
end

function grammar:execute(input_string)
  local result_string = input_string
  local stop_condition_met = false
  while not stop_condition_met do
    result_string = self:next_production(result_string)
    stop_condition_met = self:stop_condition(result_string)
  end
  return result_string
end
