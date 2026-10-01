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

## Each plan frame, all goals are re-evaluated and the highest priority valid goal is picked.
## An agent with all it's goals satisfied or invalid will chose to do nothing.
func calculate_priority(entity:Node, goap:GoapAgent, world_state:Dictionary[StringName, Variant]) -> float:
	return 0.0

## Goals are completely ignored for every frame they're found invalid.
func is_still_valid(entity:Node, goap:GoapAgent, world_state:Dictionary[StringName, Variant]) -> bool:
	return true
