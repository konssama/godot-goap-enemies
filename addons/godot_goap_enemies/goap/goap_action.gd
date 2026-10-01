extends RefCounted
class_name GoapAction

@export var action_name:StringName
@export var preconditions:Dictionary[StringName, Variant]
@export var effects:Dictionary[StringName, Variant]

func _init():
	action_name = _define_name()
	preconditions = _define_preconditions()
	effects = _define_effects()

func _to_string() -> String:
	return "Action:" + action_name

## The actions unique name.
func _define_name() -> StringName:
	return ""

## Preconditions needed for this action to be used. Will be satisfied by
## [member GoapAgent.world_state] or another actions [member GoapAction.precondition]
func _define_preconditions() -> Dictionary[StringName, Variant]:
	return {}

## Effects this action may have on [member GoapAgent.world_state].
## Effects work more as promises rather than concrete results and are purposly not set by the plugin.
## You can set them conditionaly on [method action_process] or lead the agent in a place for a sensor to pick them up.
## (e.g. a go_to_cover action can just lead the agent to cover for the eyes to see it and set
## [code]"sees_cover" = true [/code]
func _define_effects() -> Dictionary[StringName, Variant]:
	return {}

## The cost of this action being chosen when planning.
func calculate_cost(entity:Node, goap:GoapAgent, world_state:Dictionary[StringName, Variant]) -> float:
	return 0.0

## An invalid action can break the agents plan at any time and the agent will adapt if it has valid actions. 
func is_still_valid(entity:Node, goap:GoapAgent, world_state:Dictionary[StringName, Variant]) -> bool:
	return true

## The position this agent should go to to start this action. Return [code]Vector3.INF[/code] for an
## action that can be done regardless of the agents position (e.g. shoot). Can also return the position
## of a moving target and the agent will follow it, until it reaches and moves on to [method action_process].
func choose_goto_position_3d(entity:Node, goap:GoapAgent, world_state:Dictionary[StringName, Variant]) -> Vector3:
	return Vector3.INF

## The position this agent should go to to start this action. Return [code]Vector2.INF[/code] for an
## action that can be done regardless of the agents position (e.g. shoot). Can also return the position
## of a moving target and the agent will follow it, until it reaches and moves on to [method action_process].
func choose_goto_position_2d(entity:Node, goap:GoapAgent, world_state:Dictionary[StringName, Variant]) -> Vector2:
	return Vector2.INF

## Main procces of this action that runs every [code]physics_frame[/code]. Return true when this
## action is considered finished and want to move to the next one.
func action_process(entity:Node, goap:GoapAgent, world_state:Dictionary[StringName, Variant], delta:float) -> bool:
	return true
