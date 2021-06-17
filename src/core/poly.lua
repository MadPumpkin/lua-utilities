
poly = {}

function poly.assert_shape(...)
	if not ( 0 == #args % 2) then
		error("Arguments must be a sequence of numbers with even magnitude")
	else
		for v=1,#args do
			assert('number' == type(args[v]),
				"All arguments provided to poly.shape(...) must be numbers" )
		end
		return {args}
	end
end

function poly.seg(Ax, Ay, Bx, By)
	return {vec.diff(Ax, Ay, Bx, By)}
end

function poly.verts(...)
	if not ( 0 == #args % 2) then
		error("There must be an even number of numeric arguments in poly.verts(...)")
	else
		local verts = {}
		for v=1,(#args/2),2 in ipairs(args) do
			table.insert(verts, {args[v], args[v+1]})
		end
		return verts
	end
end

function poly.edges(...)
	if not ( 0 == #args % 2) then
		error("There must be an even number of numeric arguments in poly.edges(...)")
	end
	local edges = {}
	for a=1,#args in ipairs(args) do
		local b = args[ (a % (#args)) + 1 ]
		table.insert(edges, poly.seg(args[a], args[b]))
	end
	return edges
end

function poly.proj(shape, Px, Py)
	Px, Py = vec.unit(Px, Py)
	local verts = poly.verts(unpack(shape))
	local min = vec.dot(verts[1][1],verts[1][2],Px,Py)
	local max = min
	for i,v in ipairs(verts) do
		local p = dot(v[1], v[2], Px, Py)
		if p < min then min = proj end
		if p > max then max = proj end
	end
	return min, max
end

function poly.overlap(Ax, Ay, Bx, By)
	if math.range(Ax, Bx, By)
	or math.range(Ay, Bx, By)
	or math.range(Bx, Ax, Ay)
	or math.range(By, Ax, Ay) then
		return true
	else
		return false
	end
end

function poly.intersects(A, B)
	local Ae = poly.edges(A)
	local Be = poly.edges(B)
	for i,v in ipairs(Ae) do
		local Px, Py = vec.perp(v[1], v[2])
		local Ap, Bp = poly.proj(A, Px, Py)), poly.proj(B, Px, Py))
		if not poly.overlap(Ap, Bp) then return false end
	end
	for i,v in ipairs(Be) do
		local Px, Py = vec.perp(v[1], v[2])
		local Ap, Bp = poly.proj(A, Px, Py)), poly.proj(B, Px, Py))
		if not poly.overlap(Ap, Bp) then return false end
	end
end

function poly.lexicographic(shape)
	if poly.assert_shape(shape) then
		local verts = poly.verts(shape)
		table.sort(verts, function(a, b)
							if a[1] < b[1] then
								return a
							else
								if a[2] < a[1] then
									return a
								end
							end
							return b
						end)
	end
end

function poly.convex_hull(shape)
	if poly.assert_shape(shape) then
		local point_count = #A/2
		local sorted_points = poly.lexicographic(shape)
		local k = 1;
		if point_count <= 3 return sorted_points
		local hull = {}
		for i=1,point_count do
			while (k >= 3 and vec.crossz(hull[k-2][1], hull[k-2][2], hull[k-1][1], hull[k-1][2], sorted_points[i][1], sorted_points[i][2]) <= 0) do
				k = k - 1
			end
			k = k + 1
			hull[k] = sorted_points[i]
			end
		end
		for i=point_count-2,t=k+1,i>=1,-1 do
			while (k >= t and vec.crossz(hull[k-2][1], hull[k-2][2], hull[k-1][1], hull[k-1][2], sorted_points[i][1], sorted_points[i][2]) <= 0) do
				k = k - 1
			end
			k = k + 1
			hull[k] = sorted_points[i]
			end
		end
		return hull, k
	end
end