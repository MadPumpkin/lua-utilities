local obj = require 'core.obj'

GraphNode = obj.new('GraphNode')
GraphNode.states = love.handlers
GraphNode.states_stack = {}
GraphNode.state_transitions = {}
GraphNode.render_
GraphNode.current_state = 'load'

GraphNode.valid_state = function(state)
    return self.states[state] ~= nil
end

GraphNode.execute = function(state, ...)
    if self.valid_state(state) then
        return self[state](arg)
    end
end

return GraphNode