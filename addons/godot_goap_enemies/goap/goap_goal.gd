@abstract
extends RefCounted
class_name GoapGoal

@export var goal_name:StringName
@export var desired_state:Dictionary[StringName, Variant]

func _init() -> void:
	goal_name = _define_name()
	desired_state = _define_desired_state()

func _to_string() -> String:
	return "Goal:" + goal_name
	
## The goals unique name.
func _define_name() -> StringName:
	return ""

## The [member GoapAgent.world_state] needed to consider this goal satisfied. Actions will
## chain together when choosing a plan to fulfil this goal
func _define_desired_state() -> Dictionary[StringName, Variant]:
	return {}
