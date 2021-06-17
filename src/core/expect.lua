local fn = require 'fn'
local assertion = require 'assertion'

local expect = {}
expect.operator = {
  equal = true,
  not_equal = true,
  less_than = true,
  greater_than = true,
  less_than_or_equal = true,
  greater_than_or_equal = true
}

assertion.exits_on_failure(false)
assertion.prints_debug(false)

function expect.pass_string(a, b, what)
  return '[PASS]\t'..tostring(a)..' '..tostring(what)..' '..tostring(b)..'\n'
end

function expect.fail_string(a, b, what)
  return '[FAIL]\texpected '..tostring(a)..' and '..tostring(b)..' to be '..tostring(what)..'\n'
end

function expect.to_string(a, b, what, pass)
  if pass then
    return expect.pass_string(a, b, what)
  else
    return expect.pass_string(a, b, what)
  end
end

expect.__call = function(table, first)
  local chain = {
    to_be = {}
  }
  setmetatable(chain.to_be, {
    __call = function(table, operator)
      assertion.prints_debug(false)
      if type(operator) == 'boolean' then
        return assertion.equal(first, operator)
      else
        if expect.operator[operator] ~= nil then
          local second_chain = {
            to = {}
          }
          setmetatable(second_chain.to, {
            __call = function(table, second)
              local equality = assertion[operator](first, second)
              assertion.prints_debug(true)
              equality = assertion[operator](first, second, expect.to_string(first, second, operator, equality))
              assertion.prints_debug(false)
              return equality
            end
          })
          return second_chain
        else
          error('expect.operator[\''..fn.to_string(operator)..'\'] is not a valid operator')
        end
      end
    end
  })
  return chain
end

setmetatable(expect, expect)

if not expect(true).to_be('equal').to(true) or expect(true).to_be(true) then
  return expect
else
  error('An unexpected error occurred from within the expect module')
  return nil
end
