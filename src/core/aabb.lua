require 'core.vec'

aabb = {}

--[[ A new box where x is the x position and y is the y position,
w and h are w and h ]]
function aabb.box(x, y, w, h, subdivision_of)
  local box = {
    __subdivision_of=subdivision_of,
    __aabb_box=true,
    x=x,
    y=y,
    w=w,
    h=h
  }
  return box
end

function aabb.is_box(box)
  return box['__aabb_box'] ~= nil
end

function aabb.subdivide(box)
  if aabb.is_box(box) then
    box.top_left =      { __subdivision_of=box, __aabb_box=true, x, y, w/2, h/2}
    box.top_right =     { __subdivision_of=box, __aabb_box=true, x + w/2, y, w, h/2}
    box.bottom_left =   { __subdivision_of=box, __aabb_box=true, x, y + h/2, w/2, h/2}
    box.bottom_right =  { __subdivision_of=box, __aabb_box=true, x + w/2, y + h/2, w/2, h/2}
  else
    error("aabb.subdivide(box): box wasn't a box with { __aabb_box=true, x=x, y=y, w=w, h=h }'")
  end
end

-- Returns true if b
function aabb.contains(A, Px, Py)
  if A.x < Px and Px < A.w
  and A.y < Py and Py < A.h then
    return true
  end
  return false
end

-- Returns true if rectangle A intersects rectangle B
function aabb.intersects(A, B)
  return (A.x < B.w
    and A.w > B.x
    and A.y < B.h
    and A.h > B.y)
end

-- Returns a rectangular intersection of A and B
function aabb.intersection(A, B)
  local intersection = nil
  if aabb.intersects(A, B) then
    local Ix = math.max(A.x, B.x)
    local Iy = math.max(A.y, B.y)
    local Jx = math.min(A.w, B.w) - Ix
    local Jy = math.min(A.h, B.h) - Iy
    intersection = { Ix, Iy, Jx, Jy }
  end
  return intersection
end

-- Moves A, out of B
function aabb.resolve(A, B)
  local intersect = aabb.intersection(A, B)
  if intersect then
    if A.x < B.x then
      A.x = A.x + intersect.x
    else
      A.x = A.x - intersect.x
    end
  else
    if A.y > B.y then
      A.y = B.y + intersect.y
    else
      A.y = B.y - intersect.y
    end
  end
end

return aabb