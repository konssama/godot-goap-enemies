extends GoapAction2D

func _define_name() -> StringName:
	return ""

func _define_preconditions() -> Dictionary[StringName, Variant]:
	return {}

func _define_effects() -> Dictionary[StringName, Variant]:
	return {}

func calculate_cost(_entity:CharacterBody2D, _goap:GoapAgent2D, _world_state:Dictionary[StringName, Variant]) -> float:
	return 0.0

func is_still_valid(_entity:CharacterBody2D, _goap:GoapAgent2D, _world_state:Dictionary[StringName, Variant]) -> bool:
	return true

func choose_goto_position(_entity:CharacterBody2D, _goap:GoapAgent2D, _world_state:Dictionary[StringName, Variant]) -> Vector2:
	return Vector2.INF

func action_process(_entity:CharacterBody2D, _goap:GoapAgent2D, _world_state:Dictionary[StringName, Variant], _delta:float) -> bool:
	return true
