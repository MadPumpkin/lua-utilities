


local frag_shader = [[vec2 u_c = vec2(0.5,0.5);
float distanceFromLight = length(uv - u_c);
gl_FragColor = mix(vec4(1.,0.5,1.,1.), vec4(0.,0.,0.,1.), distanceFromLight*2.0)"]]

local vert_shader = [[gl_Position = _mvProj * vec4(vertex, 1.0); uv = uv1;]]