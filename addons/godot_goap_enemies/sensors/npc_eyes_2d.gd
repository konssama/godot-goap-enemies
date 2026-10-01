extends Area2D
class_name NpcEyes2D

## Node groups these eyes will register. Will automatically provide [code]"sees_group"[/code]
## for it's [member GoapAgent.world_state]
@export var look_for_groups:Array[StringName]
@export var goap_agent:GoapAgent2D

var seen_group_items:Dictionary[StringName, Array] #Array[Node2D]

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	for group in look_for_groups:
		seen_group_items[group] = []
		goap_agent.world_state["sees_" + group] = false

func _on_body_entered(body:Node2D):
	for group in body.get_groups():
		if group in look_for_groups:
			if body not in seen_group_items[group]:
				_register_node(body, group)

func _on_body_exited(body:Node2D):
	for group in body.get_groups():
		if group in look_for_groups:
			_remove_node(body, group)

func _register_node(node:Node2D, group:StringName):
	seen_group_items[group].append(node)
	goap_agent.world_state["sees_" + group] = true

func _remove_node(node:Node2D, group:StringName):
	seen_group_items[group].erase(node)
	if get_seen_in_group(group).is_empty():
		goap_agent.world_state["sees_" + group] = false

func get_seen_in_group(group:StringName) -> Array[Node2D]:
	return seen_group_items[group]

func get_closest_in_group(group:StringName) -> Node2D:
	var closest_node:Node2D
	var closest_dist:float = INF
	for node in get_seen_in_group(group):
		var dist := global_position.distance_squared_to(node.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_node = node
	return closest_node
