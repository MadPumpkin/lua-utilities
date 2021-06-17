local assertion = {}
assertion.__index = assertion
assertion.prints = true
assertion.exits = true

function assertion.prints_debug(enabled)
  local debug = enabled or not(assertion.prints)
  assertion.prints = debug
end

function assertion.exits_on_failure(enabled)
  local exits = enabled or not(assertion.exits)
  assertion.exits = exits
end

function assertion.print(string)
  if assertion.prints_debug then
    print(string)
  end
end

function assertion.that(truth, message)
  if assertion.exits then
    assert(truth, message)
  else
    print(message)
    return truth
  end
end

function assertion.method_string(method_name, ...)
  local state_string = 'assertion.'..tostring(method_name)
  for k,v in pairs(arg) do
    state_string = state_string..' <'..tostring(k)..', '..tostring(v)..'>\t'
  end
  return state_string
end

function assertion.equal(a, b, message)
  local method_string = assertion.method_string('equal', a, b, message)
  local equality = (a == b)
  assertion.print(method_string)
  assertion.that(equality, method_string)
  return equality
end

function assertion.not_equal(a, b, message)
  local method_string = assertion.method_string('not_equal', a, b, message)
  local equality = (a ~= b)
  assertion.print(method_string)
  assertion.that(equality, method_string)
  return equality
end

function assertion.less_than(a, b, message)
  local method_string = assertion.method_string('less_than', a, b, message)
  local equality = (a < b)
  assertion.print(method_string)
  assertion.that(equality, method_string)
  return equality
end

function assertion.greater_than(a, b, message)
  local method_string = assertion.method_string('greater_than', a, b, message)
  local equality = (a > b)
  assertion.print(method_string)
  assertion.that(equality, method_string)
  return equality
end

function assertion.less_than_or_equal(a, b, message)
  local method_string = assertion.method_string('less_than_or_equal', a, b, message)
  local equality = (a <= b)
  assertion.print(method_string)
  assertion.that(equality, method_string)
  return equality
end

function assertion.greater_than_or_equal(a, b, message)
  local method_string = assertion.method_string('greater_than_or_equal', a, b, message)
  local equality = (a >= b)
  assertion.print(method_string)
  assertion.that(equality, method_string)
  return equality
end

return assertion
