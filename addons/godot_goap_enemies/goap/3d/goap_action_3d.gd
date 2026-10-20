extends GoapAction
class_name GoapAction3D

var goto_pos:Vector3 = -Vector3.INF

func awake(entity:CharacterBody3D, goap:GoapAgent3D, world_state:Dictionary[StringName, Variant]) -> void:
	pass

func start(entity:CharacterBody3D, goap:GoapAgent3D, world_state:Dictionary[StringName, Variant]) -> void:
	pass

func end(entity:CharacterBody3D, goap:GoapAgent3D, world_state:Dictionary[StringName, Variant]) -> void:
	pass

## The cost of this action being chosen when planning.
func calculate_cost(entity:CharacterBody3D, goap:GoapAgent3D, world_state:Dictionary[StringName, Variant]) -> float:
	return 0.0

## An invalid action can break the agents plan at any time and the agent will adapt if it has valid actions. 
func is_still_valid(entity:CharacterBody3D, goap:GoapAgent3D, world_state:Dictionary[StringName, Variant]) -> bool:
	return true

## The position this agent should go to to start this action. Return [code]Vector3.INF[/code] for an
## action that can be done regardless of the agents position (e.g. shoot). Can also return the position
## of a moving target and the agent will follow it, until it reaches and moves on to [method action_process].
func choose_goto_position(entity:CharacterBody3D, goap:GoapAgent3D, world_state:Dictionary[StringName, Variant]) -> Vector3:
	return Vector3.INF

## Main procces of this action that runs every [code]physics_frame[/code]. Return true when this
## action is considered finished and want to move to the next one.
func action_process(entity:CharacterBody3D, goap:GoapAgent3D, world_state:Dictionary[StringName, Variant], delta:float) -> bool:
	return true
