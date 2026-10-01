extends GoapGoal

func _to_string() -> String:
	return "Goal:" + goal_name

func _define_name() -> StringName:
	return ""

func _define_desired_state() -> Dictionary[StringName, Variant]:
	return {}

func calculate_priority(_entity:Node, _goap:GoapAgent, _world_state:Dictionary[StringName, Variant]) -> float:
	return 0.0

func is_still_valid(_entity:Node, _goap:GoapAgent, _world_state:Dictionary[StringName, Variant]) -> bool:
	return true
