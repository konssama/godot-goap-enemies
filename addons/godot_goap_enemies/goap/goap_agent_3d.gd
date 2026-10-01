@icon("res://addons/godot_goap_enemies/goap/goap_agent_3d.svg")
extends GoapAgent
class_name GoapAgent3D

## The [CharacterBody3D] that this agent controls. Note that this agent calls
## [method CharacterBody3D.move_and_slide] on it's own so you should not call it while
## the agent is active, as that will move the entity double the intended amount
@export var entity:CharacterBody3D
## The [NavigationAgent3D] that provides paths when moving.
@export var nav_agent:NavigationAgent3D
@export var walk_speed:float
@export var turn_speed: float

func _goto_process(delta:float) -> GotoQueryResult:
	if nav_agent.is_target_reached():
		return GotoQueryResult.GOTO_CLEARED
	
	var new_destination:Vector3 = _current_action.choose_goto_position_3d(entity, self, world_state)
	if nav_agent.target_position.distance_squared_to(new_destination) >= 1.0:
		nav_agent.target_position = new_destination
	
	if not nav_agent.is_target_reachable():
			return GotoQueryResult.TARGET_UNREACHABLE
	
	var next_point := nav_agent.get_next_path_position()
	smooth_look_at(next_point, delta)
	entity.velocity = -entity.global_basis.z * walk_speed * delta
	entity.move_and_slide()
	
	return GotoQueryResult.NEEDS_REPOSITION

func smooth_look_at(target: Vector3, delta: float, yaw_only: bool = true) -> void:
	var direction := target - entity.global_position
	if yaw_only:
		direction.y = 0.0

	if direction.length_squared() < 0.0001:
		return

	var weight := 1.0 - exp(-turn_speed * delta)

	if yaw_only:
		var target_yaw := atan2(-direction.x, -direction.z)
		entity.rotation.y = lerp_angle(entity.rotation.y, target_yaw, weight)
	else:
		var target_basis := Basis.looking_at(direction.normalized(), Vector3.UP)
		entity.global_basis = entity.global_basis.orthonormalized().slerp(target_basis, weight)

func check_needs_repositioning(action:GoapAction) -> GotoQueryResult:
	var goto_pos:Vector3 = action.choose_goto_position_3d(self.entity, self, world_state)
	if goto_pos.is_finite():
		nav_agent.target_position = goto_pos
		if not nav_agent.is_target_reachable():
			return GotoQueryResult.TARGET_UNREACHABLE
		return GotoQueryResult.NEEDS_REPOSITION
	return GotoQueryResult.GOTO_CLEARED # infinite pos means no repositioning needed

func is_action_reachable(action:GoapAction) -> bool:
	var pos = action.choose_goto_position_3d(entity, self, world_state)
	if not pos.is_finite():
		return true # you're already at valid position
	
	var map := entity.get_world_3d().navigation_map
	var path := NavigationServer3D.map_get_path(map, entity.global_position, pos, true)
	if path.is_empty():
		return false
	return path[path.size() - 1].distance_to(pos) <= nav_agent.target_desired_distance
