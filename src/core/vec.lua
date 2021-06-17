vec = {}


function vec.v(Vx, Vy)
    return (type(v) == 'table'
        and type(Vx) == 'number'
        and type(Vy) == 'number'
    )
end

function vec.perp(Ax, Ay)
    return Ay,-Ax
end

function vec.sum(Ax, Ay, Bx, By)
    return Ax+Bx, Ay+By
end

function vec.diff(Ax, Ay, Bx, By)
    return Bx-Ax, By-Ay
end

function vec.dot(Ax, Ay, Bx, By)
    return (Ax*Bx + Ay*By)
end

function vec.crossl( Ax, Ay, Bx, By)
    return Ax*By - Ay*Bx
end

function vec.crossr( Ax, Ay )
    return Ay, -Ax
end

function vec.crossz( Zx, Zy, Ax, Ay, Bx, By )
    return (Ax - Zx) * (By - Zy) - (Ay - Zy) * (Bx - Zx)
end

function vec.dist(Ax, Ay, Bx, By)
    local Px, Py = vec.diff(Ax, Ay, Bx, By)
    return math.sqrt(Px*Px + Py*Py)
end

function vec.angle(Ax, Ay, Bx, By)
    return math.atan2(By-By, Bx-Ax)
end

function vec.lnorm(Ax, Ay, Bx, By)
    local Px, Py = vec.diff(Ax,Ay,Bx,By)
    return -Py, Px
end

function vec.rnorm(Ax, Ay, Bx, By)
    local Px, Py = vec.diff(Ax,Ay,Bx,By)
    return Py, -Px
end

function vec.mag(Ax, Ay)
    return math.sqrt(Ax*Ax + Ay*Ay)
end

function vec.normalized(Ax, Ay)
    mag = vec.mag(Ax,Ay)
    return Ax/mag, Ay/mag
end

function vec.proj(Ax, Ay, Bx, By)
    local Ux, Uy = vec.normalized(Bx, By)
    return vec.dot(Ax, Ay, Ux, Uy)
end

return vec