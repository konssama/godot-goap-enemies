extends RefCounted
class_name GoapServer

#region Planner

const MAX_ITERATIONS := 5000
const DEBUG := false


class PlanNode:
	var action:GoapAction
	var h:float
	var g:float
	var prev:PlanNode
	var state_goal:Dictionary[StringName, Variant] = {} # states we want this node to fulfil
	
	func _init(represented_action:GoapAction) -> void:
		action = represented_action
	func f():
		return g+h
	func _to_string() -> String:
		return str(action) if action else "goal"

static func create_plan(desired_state:Dictionary[StringName, Variant], action_list:Array[GoapAction], agent:GoapAgent) -> Array[GoapAction]:
	# TODO cache this on _ready for each agent and find a cheap way to merge temporary actions 
	var effect_table := _build_effect_table(action_list)

	var open:Array[PlanNode] = []

	var start := PlanNode.new(null) # the root is the goal, not an action
	start.state_goal = desired_state.duplicate()
	start.h = _heuristic(agent.world_state, start.state_goal)
	open.append(start)

	var iterations := 0
	while open.size() > 0 and iterations < MAX_ITERATIONS:
		iterations += 1

		var current := open[0]
		for item in open:
			if (item.f() < current.f()) or (item.f() == current.f() and item.h < current.h):
				current = item
		open.erase(current)

		if DEBUG: print("PLANNER: expanding ", str(current), " f=", current.f())

		# if h reaches 0 that means we're already at our goal state
		if current.action and current.h == 0.0:
			var plan := _reconstruct_path(current)
			if is_plan_valid(plan, desired_state, agent):
				if DEBUG: print("PLANNER: plan found, cost ", current.f())
				return plan

		for action in _get_neighbors(current, effect_table, agent):
			var child := _make_node(action, current, agent)
			if child == null:
				continue
			child.g = current.g + action.calculate_cost(agent.entity, agent, agent.world_state)
			open.append(child)

	return []


# get actions that can affect the node we want to build off of
static func _get_neighbors(node:PlanNode, effect_table:Dictionary, agent:GoapAgent) -> Array[GoapAction]:
	var neighbors:Array[GoapAction] = []
	var world := agent.world_state
	
	for key in node.state_goal:
		if world.has(key) and world[key] == node.state_goal[key]:
			continue
		if not effect_table.has(key):
			continue
		
		for action:GoapAction in effect_table[key]:
			if action.effects[key] != node.state_goal[key]:
				continue
			if action in neighbors:
				continue
			neighbors.append(action)
	
	return neighbors


static func _build_effect_table(action_list:Array[GoapAction]) -> Dictionary:
	var table := {}
	for action in action_list:
		for key in action.effects:
			if not table.has(key):
				table[key] = []
			table[key].append(action)
	return table


static func _make_node(action:GoapAction, parent:PlanNode, agent:GoapAgent) -> PlanNode:
	var node := PlanNode.new(action)
	node.prev = parent
	node.state_goal = parent.state_goal.duplicate()

	# effects satisfy goal keys so those no longer need to hold before the action
	for key in action.effects:
		if node.state_goal.has(key) and node.state_goal[key] == action.effects[key]:
			node.state_goal.erase(key)

	# preconditions become new requirements
	for key in action.preconditions:
		if node.state_goal.has(key) and node.state_goal[key] != action.preconditions[key]:
			return null # contradiction means this chain is dead
		node.state_goal[key] = action.preconditions[key]

	node.h = _heuristic(agent.world_state, node.state_goal)
	return node


static func is_plan_valid(plan:Array[GoapAction], desired_state:Dictionary, agent:GoapAgent) -> bool:
	if plan.is_empty():
		return false
	var sim:Dictionary = agent.world_state.duplicate()
	for action in plan:
		if not satisfies(sim, action.preconditions):
			return false
		sim.merge(action.effects, true)
	return satisfies(sim, desired_state)


static func _heuristic(world:Dictionary, state_goal:Dictionary) -> float:
	var unmet := 0
	for key in state_goal:
		if not world.has(key) or world[key] != state_goal[key]:
			unmet += 1
	return float(unmet)


static func satisfies(state:Dictionary, desired_state:Dictionary) -> bool:
	if desired_state.is_empty():
		return true
	for key in desired_state:
		if not state.has(key) or state[key] != desired_state[key]:
			return false
	return true


static func _reconstruct_path(node:PlanNode) -> Array[GoapAction]:
	var plan:Array[GoapAction] = []
	var current := node
	while current.action != null:
		plan.push_back(current.action)
		current = current.prev
	return plan

#endregion
