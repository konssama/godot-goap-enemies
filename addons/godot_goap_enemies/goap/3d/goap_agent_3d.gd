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
	
	var new_destination:Vector3
	if _current_action.is_tracking:
		new_destination = _current_action.choose_goto_position(entity, self, world_state)
	elif not _current_action.is_tracking:
		if not _current_action.goto_pos.is_finite():
			_current_action.goto_pos = _current_action.choose_goto_position(entity, self, world_state)
		new_destination = _current_action.goto_pos
	
	#if entity.global_position.distance_squared_to(new_destination) >= 1.0:
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
	var goto_pos:Vector3 = action.choose_goto_position(self.entity, self, world_state)
	if goto_pos.is_finite():
		nav_agent.target_position = goto_pos
		if not nav_agent.is_target_reachable():
			return GotoQueryResult.TARGET_UNREACHABLE
		return GotoQueryResult.NEEDS_REPOSITION
	return GotoQueryResult.GOTO_CLEARED # infinite pos means no repositioning needed

func is_action_reachable(action:GoapAction) -> bool:
	var pos = action.choose_goto_position(entity, self, world_state)
	if not pos.is_finite():
		return true # you're already at valid position
	
	var map := entity.get_world_3d().navigation_map
	var path := NavigationServer3D.map_get_path(map, entity.global_position, pos, true)
	if path.is_empty():
		return false
	return path[path.size() - 1].distance_to(pos) <= nav_agent.target_desired_distance

func get_random_reachable_point(min_dist: float, max_dist: float, origin_pos:Vector3=entity.global_position) -> Vector3:
	# ai cause i don't know any geometry
	if min_dist < nav_agent.target_desired_distance:
		# don't pick a small distance you're already "at"
		min_dist = nav_agent.target_desired_distance
	
	if min_dist > max_dist:
		#var tmp := min_dist
		#min_dist = max_dist
		#max_dist = tmp
		push_error("min larger than max")


	var map: RID = nav_agent.get_navigation_map()
	var layers: int = nav_agent.navigation_layers

	# Start from the navmesh point closest to the agent
	var origin: Vector3 = NavigationServer3D.map_get_closest_point(map, origin_pos)

	# Pick a random heading and a random wanted distance
	var angle := randf() * TAU
	var wanted := randf_range(min_dist, max_dist)
	var dir := Vector3(cos(angle), 0.0, sin(angle))

	# Aim at max_dist so the path is long enough to contain a point at `wanted`.
	# If the target is off-mesh or unreachable, the path simply ends at the
	# closest reachable point to it, so the path is always walkable.
	var target := origin + dir * max_dist
	var path: PackedVector3Array = NavigationServer3D.map_get_path(map, origin, target, true, layers)

	var farthest := origin
	var farthest_dist := 0.0

	# Walk the path and find where it first crosses `wanted` distance from origin
	for i in range(1, path.size()):
		var a := path[i - 1]
		var b := path[i]

		if origin.distance_to(b) >= wanted:
			# Segment/sphere intersection: |a + t*(b-a) - origin| = wanted
			var ab := b - a
			var ao := a - origin
			var qa := ab.dot(ab)
			var qb := 2.0 * ao.dot(ab)
			var qc := ao.dot(ao) - wanted * wanted
			var disc := maxf(qb * qb - 4.0 * qa * qc, 0.0)
			var t := clampf((-qb + sqrt(disc)) / (2.0 * qa), 0.0, 1.0) if qa > 0.0 else 1.0
			return a + ab * t

		var d := origin.distance_to(b)
		if d > farthest_dist:
			farthest_dist = d
			farthest = b

	# The reachable area in that direction is shorter than `wanted` (a wall or
	# the edge of the navmesh), so use the farthest reachable point instead.
	return farthest
