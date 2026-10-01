extends Node

var agent:GoapAgent
var agent_id:int

func _ready() -> void:
	agent = get_parent()
	agent_id = agent.get_instance_id()
	EngineDebugger.send_message("goap:create_agent", [agent_id])
	EngineDebugger.send_message("goap:set_agemt_name", [agent_id, agent.entity.name])
	
	tree_exiting.connect(
		EngineDebugger.send_message.bind("goap:clear_agent", [agent_id])
	)
	agent.renamed.connect(
		EngineDebugger.send_message.bind("goap:set_agemt_name", [agent_id, agent.entity.name])
	)
	agent.goal_chosen.connect(
		func(goal:GoapGoal):
			EngineDebugger.send_message("goap:set_goal", [agent_id, goal.goal_name])
	)
	agent.action_began_goto.connect(
		func(action:GoapAction):
			EngineDebugger.send_message("goap:set_state", [agent_id, "GOTO"])
	)
	agent.action_began_animating.connect(
		func(action:GoapAction):
			EngineDebugger.send_message("goap:set_state", [agent_id, "ANIMATING"])
	)
	agent.fresh_plan_chosen.connect(
		func(plan:Array[GoapAction]):
			var names = _helper_get_actions_as_names(plan)
			EngineDebugger.send_message("goap:set_plan", [agent_id, names, 0])
	)
	agent.action_chosen.connect(
		func(_action:GoapAction):
			var names = _helper_get_actions_as_names(agent._current_plan)
			EngineDebugger.send_message("goap:set_plan", [agent_id, names, agent._plan_step])
	)

func _physics_process(delta: float) -> void:
	EngineDebugger.send_message("goap:set_world_state", [agent_id, str(agent.world_state)])

func _helper_get_actions_as_names(actions:Array[GoapAction]) -> Array[String]:
	var names:Array[String]
	for action in actions:
		names.append(action.action_name)
	return names
