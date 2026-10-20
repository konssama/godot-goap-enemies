@abstract
extends RefCounted
class_name GoapAction

@export var action_name:StringName
@export var preconditions:Dictionary[StringName, Variant]
@export var effects:Dictionary[StringName, Variant]

var is_tracking:bool = false

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
## [code]"sees:cover" = true [/code]
func _define_effects() -> Dictionary[StringName, Variant]:
	return {}
