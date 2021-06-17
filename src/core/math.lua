function math.mod(a, b)
  return a - math.floor(a/b)*b
end
  
function math.round(x)
  return (x >= 0
    and math.floor(x+0.5)
    or math.ceil(x-0.5))
end

function math.truncate(x, digits)
  local shift = 10 ^ digits
  return math.floor( x*shift + 0.5 ) / shift
end

function math.range(x, near, far)
  local low, high = near, far
  if high < low then
    low = high
    high = near
  end
  return x >= near and x <= far
end

function math.lerp(P, Q, interpolant)
  return ((1 - interpolant) * P + interpolant * Q)
end

function math.lerp_point(Px, Py, Px, Pq, interpolant)
  return {
    x=((1 - interpolant.x) * P.x + interpolant.x * Q.x),
    y=((1 - interpolant.y) * P.y + interpolant.y * Q.y)
  }
end

function math.sign(v)
  if v > 0 then
    return 1
  elseif v == 0 then
    return 0
  else
    return -1
  end
end

math.op = {
  neg = function(n) return not(n) end,
  add = function(n,m) return n + m end,
  sub = function(n,m) return n - m end,
  mul = function(n,m) return n * m end,
  div = function(n,m) return n / m end,
  gt  = function(n,m) return n > m end,
  lt  = function(n,m) return n < m end,
  eq  = function(n,m) return n == m end,
  le  = function(n,m) return n <= m end,
  ge  = function(n,m) return n >= m end,
  ne  = function(n,m) return n ~= m end,
  truncate  = math.truncate,
  round     = math.round,
  range     = math.range,
  lerp      = math.lerp,
  mod       = math.mod,
  pow       = math.pow,
  sign      = math.sign 
}