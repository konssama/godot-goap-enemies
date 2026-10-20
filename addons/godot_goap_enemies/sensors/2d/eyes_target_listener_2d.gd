extends Node
class_name NpcEyesTargetListener2D

@export var target_group:StringName

@export var melee_dist_margin:float
@export var close_dist_margin:float

@export var low_awareness_frames:int
@export var max_awareness:int

var eyes_area:NpcEyes2D
var agent:GoapAgent2D

var _target:Node2D: set=_on_new_target
var _current_awareness := 0
var _current_distance:float
var _candidates: Array[Node2D] = []

func _ready() -> void:
	eyes_area = get_parent()
	
	agent = eyes_area.goap_agent
	eyes_area.body_entered.connect(_on_body_entered)
	eyes_area.body_exited.connect(_on_body_exited)
	
	agent.world_state[target_group+"_target_dist"] = GoapLibrary.Distance.INFINITE
	agent.world_state[target_group+"_target_awareness"] = GoapLibrary.Awareness.NONE
	agent.world_state[target_group+"_target_dead"] = false

func _physics_process(delta:float) -> void:
	if _current_awareness <= 0:
		agent.world_state[target_group+"_target_awareness"] = GoapLibrary.Awareness.NONE
	elif _current_awareness <= low_awareness_frames:
		agent.world_state[target_group+"_target_awareness"] = GoapLibrary.Awareness.LOW
	else:
		agent.world_state[target_group+"_target_awareness"] = GoapLibrary.Awareness.HIGH
	
	if _target and not _target.is_inside_tree(): # TODO check if this is a proper way to check dead player
		agent.world_state[target_group+"_target_dead"] = true
	
	if not _target:
		_current_awareness -= 1
		_current_awareness = maxi(_current_awareness, 0)
		agent.world_state[target_group+"_target_dist"] = GoapLibrary.Distance.INFINITE
		return
	else:
		_current_awareness += 1
		_current_awareness = mini(_current_awareness, max_awareness)
	
	_current_distance = eyes_area.global_position.distance_to(_target.global_position)
	if _current_distance <= melee_dist_margin:
		agent.world_state[target_group+"_target_dist"] = GoapLibrary.Distance.MELEE
	elif _current_distance <= close_dist_margin:
		agent.world_state[target_group+"_target_dist"] = GoapLibrary.Distance.CLOSE
	else:
		agent.world_state[target_group+"_target_dist"] = GoapLibrary.Distance.FAR

func _on_body_entered(body:Node2D) -> void:
	if _target:
		return
	if not body.is_in_group(target_group):
		return
	
	_target = body

func _on_body_exited(body:Node2D) -> void:
	if body == _target:
		_target = null
		var bodies:Array = eyes_area.get_overlapping_bodies()
		for b in bodies:
			if b.is_in_group(target_group):
				_target = b

func _on_new_target(t:Node2D):
	_target = t
	agent.world_state[target_group+"_target_dead"] = false

func get_target() -> Node2D:
	return _target
