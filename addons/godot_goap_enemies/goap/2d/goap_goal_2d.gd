extends GoapGoal
class_name GoapGoal2D

func awake(entity:CharacterBody2D, goap:GoapAgent2D, world_state:Dictionary[StringName, Variant]) -> void:
	pass

func start(entity:CharacterBody2D, goap:GoapAgent2D, world_state:Dictionary[StringName, Variant]) -> void:
	pass

func end(entity:CharacterBody2D, goap:GoapAgent2D, world_state:Dictionary[StringName, Variant]) -> void:
	pass

## Each plan frame, all goals are re-evaluated and the highest priority valid goal is picked.
## An agent with all it's goals satisfied or invalid will chose to do nothing.
func calculate_priority(entity:CharacterBody2D, goap:GoapAgent2D, world_state:Dictionary[StringName, Variant]) -> float:
	return 0.0

## Goals are completely ignored for every frame they're found invalid.
func is_still_valid(entity:CharacterBody2D, goap:GoapAgent2D, world_state:Dictionary[StringName, Variant]) -> bool:
	return true
