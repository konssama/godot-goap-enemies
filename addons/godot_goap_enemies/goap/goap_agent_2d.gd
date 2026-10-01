@icon("res://addons/godot_goap_enemies/goap/goap_agent_2d.svg")
extends GoapAgent
class_name GoapAgent2D

## The [CharacterBody2D] that this agent controls. Note that this agent calls
## [method CharacterBody2D.move_and_slide] on it's own so you should not call it while
## the agent is active, as that will move the entity double the intended amount
@export var entity:CharacterBody2D
## The [NavigationAgent2D] that provides paths when moving.
@export var nav_agent:NavigationAgent2D
@export var walk_speed:float
@export var turn_speed: float

func _goto_process(delta:float) -> GotoQueryResult:
	if nav_agent.is_target_reached():
		return GotoQueryResult.GOTO_CLEARED
	
	var new_destination:Vector2 = _current_action.choose_goto_position_2d(entity, self, world_state)
	if nav_agent.target_position.distance_squared_to(new_destination) >= 1.0:
		nav_agent.target_position = new_destination
	
	if not nav_agent.is_target_reachable():
			return GotoQueryResult.TARGET_UNREACHABLE
	
	var next_point := nav_agent.get_next_path_position()
	smooth_look_at(next_point, delta)
	entity.velocity = -entity.global_basis.z * walk_speed * delta
	entity.move_and_slide()
	
	return GotoQueryResult.NEEDS_REPOSITION

func smooth_look_at(target: Vector2, delta: float) -> void:
	var direction := target - entity.global_position

	if direction.length_squared() < 0.0001:
		return

	var weight := 1.0 - exp(-turn_speed * delta)
	var target_angle := direction.angle()
	entity.global_rotation = lerp_angle(entity.global_rotation, target_angle, weight)

func check_needs_repositioning(action:GoapAction) -> GotoQueryResult:
	var goto_pos:Vector2 = action.choose_goto_position_2d(self.entity, self, world_state)
	if goto_pos.is_finite():
		nav_agent.target_position = goto_pos
		if not nav_agent.is_target_reachable():
			return GotoQueryResult.TARGET_UNREACHABLE
		return GotoQueryResult.NEEDS_REPOSITION
	return GotoQueryResult.GOTO_CLEARED # infinite pos means no repositioning needed

func is_action_reachable(action:GoapAction) -> bool:
	var pos = action.choose_goto_position_2d(entity, self, world_state)
	if not pos.is_finite():
		return true # you're already at valid position
	
	var map := entity.get_world_2d().navigation_map
	var path := NavigationServer2D.map_get_path(map, entity.global_position, pos, true)
	if path.is_empty():
		return false
	return path[path.size() - 1].distance_to(pos) <= nav_agent.target_desired_distance
