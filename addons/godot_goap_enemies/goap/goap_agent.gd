@abstract
extends Node
class_name GoapAgent

enum ActionState {IDLE, GOTO, EXECUTE}
enum GotoQueryResult {GOTO_CLEARED, NEEDS_REPOSITION, TARGET_UNREACHABLE}
enum PlanAbandonedReasons {GOAL_CHANGED, GOAL_UNSATISFIED, ACTION_INVALID, PLAN_INVALID,  GOTO_UNREACHABLE}

signal goal_chosen(goal:GoapGoal) ## can fire multiple times for the same goal if it is chosen again.
signal fresh_goal_chosen(goal:GoapGoal)

signal fresh_plan_chosen(plan:Array[GoapAction])
signal plan_successful()
signal plan_abandoned(reason:PlanAbandonedReasons)

signal action_chosen(action:GoapAction)
signal action_began_goto(action:GoapAction)
signal action_began_animating(action:GoapAction)
#signal smart_action_chosen(action:GoapSmartObjectAction, object:GoapSmartObject)

const DEBUGGER_ATTACHMENT = preload("res://addons/godot_goap_enemies/debugger/agent_attachment.gd")

## Array of goals accessed by [StringName]. All goals need to be declared in [code]"res://addons/godot_goap_enemies/goap_library.gd"[/code]
@export var goals:Array[StringName]
## Array of actions accessed by [StringName]. All actions need to be declared in [code]"res://addons/godot_goap_enemies/goap_library.gd"[/code]
@export var actions:Array[StringName]

## Store node references to use as abstractions in action scripts or interface with
## your other game systems. Want a global "shoot" action for enemies that shoot different projectiles?
## Use [method get_component] to get the [code]"ranged_weapon"[/code] node you stored
## and let that handle it.
@export var components:Dictionary[StringName, Node]
## Adds a child object on _ready to make this agent visible in the debugger tab
@export var enable_debugger := false

## Main heart of GOAP that all plans are made based on. Can be updated by sensors or actions.
## The world_state stores what this agent knows about the world and is not supposed to be a 1:1 representation of it.
var world_state:Dictionary[StringName, Variant]

var _goal_scripts:Array[GoapGoal] = []
var _action_scripts:Array[GoapAction] = []

var _action_state:ActionState = ActionState.IDLE

var _current_goal:GoapGoal
var _current_action:GoapAction
var _current_plan:Array[GoapAction]
var _plan_step:int = 0

var _is_paused_manually := false
var _pause_frames := 0

## Assigned on ready to control what frames planning runs on. Changing this will break monitors.
var thread_num:int

func _ready() -> void:
	add_to_group("goap_agents")
	
	for g in goals:
		if GoapLibrary.goals_library.has(g):
			var new = GoapLibrary.goals_library[g].new()
			_goal_scripts.append(new)
			new.awake(self.entity, self, world_state)
		else:
			push_error("GOAP: No goal ", g, " in GoapLibrary")
	for a in actions:
		if GoapLibrary.actions_library.has(a):
			var new = GoapLibrary.actions_library[a].new()
			_action_scripts.append(new)
			new.awake(self.entity, self, world_state)
		else:
			push_error("GOAP: No action ", a, " in GoapLibrary")
	
	for c in components.keys():
		world_state["has_" + c] = true
	
	GoapServer.register_agent(self)
	
	plan_abandoned.connect(print_abandonment_issue)
	
	if enable_debugger:
		var attachment = DEBUGGER_ATTACHMENT.new()
		add_child(attachment)
		await attachment.ready

func _physics_process(delta: float) -> void:
	if not _is_paused_manually:
		# bit of a weird if statement, but i want the plan to pause for _is_paused_manually
		# but continue for _pause_frames>0. It would be a shame if it needed to plan for the 
		# last pause frame and then have to wait again for it's turn
		if Engine.get_physics_frames() % GoapServer.THREAD_NUM == thread_num:
			var start_time = Time.get_ticks_usec()
			_plan_process(delta)
			var end_time = Time.get_ticks_usec() - start_time
			GoapServer.report_planning_time(end_time)
			#print("ticked at ", Engine.get_physics_frames(), " time: ", end_time)
		if _pause_frames > 0:
			_pause_frames -= 1
			_pause_frames = max(0, _pause_frames)
			return
	else:
		return
	
	if _current_plan and not GoapServer.is_plan_valid(_current_plan, _current_goal.desired_state, self):
		plan_abandoned.emit(PlanAbandonedReasons.PLAN_INVALID)
		_clear_plan()
	
	match _action_state:
		ActionState.GOTO:
			var result := _goto_process(delta)
			if result == GotoQueryResult.GOTO_CLEARED:
				_action_state = ActionState.EXECUTE
				action_began_animating.emit(_current_action)
				
		ActionState.EXECUTE:
			var finished := _current_action.action_process(self.entity, self, world_state, delta)
			if finished:
				_action_state = ActionState.IDLE
				_plan_step += 1
				if _plan_step < _current_plan.size():
					# action will actually be entered next plan tick
					# but it's simpler to emit here and shouldn't make a dif
					action_chosen.emit(_current_plan[_plan_step])

func _plan_process(delta: float) -> void:
	var best_goal := _get_best_goal()
	if not best_goal:
		return # all goals satisfied, nothing to do this frame
	
	goal_chosen.emit(best_goal)
	if best_goal == _current_goal:
		if _plan_step >= _current_plan.size(): # plan completed
			#print("PLAN COMPLETED ", _plan_step, " ", _current_plan)
			_clear_plan()
			if GoapServer.satisfies(world_state, _current_goal.desired_state):
				plan_successful.emit() # all went well
			else:
				plan_abandoned.emit(PlanAbandonedReasons.GOAL_UNSATISFIED)
			_current_goal = null
			return # we've finished our plan so let's get a new one next tick

		# continue to next action
		if _current_action:
			_current_action.end(self.entity, self, world_state)
		_current_action = _current_plan[_plan_step]
		_current_action.start(self.entity, self, world_state)
		
		if not _current_action.is_still_valid(self.entity, self, world_state):
			#print("ACTION INVALID")
			_clear_plan()
			plan_abandoned.emit(PlanAbandonedReasons.ACTION_INVALID)
			return
		if _action_state == ActionState.IDLE:
			#print("checking reposition")
			match check_needs_repositioning(_current_action):
				GotoQueryResult.NEEDS_REPOSITION:
					# enter goto state
					_action_state = ActionState.GOTO
					action_began_goto.emit(_current_action)
				GotoQueryResult.GOTO_CLEARED:
					# enter animate state
					_action_state = ActionState.EXECUTE
					action_began_animating.emit(_current_action)
				GotoQueryResult.TARGET_UNREACHABLE:
					#print("TARGET UNREACHABLE ", str(_current_action))
					_clear_plan()
					plan_abandoned.emit(PlanAbandonedReasons.GOTO_UNREACHABLE)
					_action_state = ActionState.IDLE
	else:
		#print("GOAL CHANGED FROM TO", str(_current_goal), str(best_goal))
		_clear_plan()
		plan_abandoned.emit(PlanAbandonedReasons.GOAL_CHANGED)
		if _current_goal:
			_current_goal.end(self.entity, self, world_state)
		_current_goal = best_goal
		_current_goal.start(self.entity, self, world_state)
		fresh_goal_chosen.emit(_current_goal)
		_current_plan = GoapServer.create_plan(_current_goal.desired_state, _action_scripts, self)
		print(_current_plan)
		fresh_plan_chosen.emit(_current_plan)

func check_needs_repositioning(action:GoapAction) -> GotoQueryResult:
	return GotoQueryResult.GOTO_CLEARED # implemented differently for 2d and 3d agents

func _goto_process(delta:float) -> GotoQueryResult:
	return GotoQueryResult.GOTO_CLEARED # implemented differently for 2d and 3d agents

func is_action_reachable(action:GoapAction) -> bool:
	return true # implemented differently for 2d and 3d agents

func _clear_plan():
	_action_state = ActionState.IDLE
	_current_plan.clear()
	_plan_step = 0

func _get_best_goal() -> GoapGoal:
	var min_priority:float = -INF
	var chosen_goal:GoapGoal
	for g in _goal_scripts:
		if not g.is_still_valid(self.entity, self, world_state):
			continue # goal invalid
		if GoapServer.satisfies(world_state, g.desired_state):
			continue # goal already satisfied
		
		var new_p := g.calculate_priority(self.entity, self, world_state)
		if new_p > min_priority:
			min_priority = new_p
			chosen_goal = g
	return chosen_goal

func start():
	_is_paused_manually = false

func pause():
	_is_paused_manually = true

func is_paused() -> bool:
	return _is_paused_manually or _pause_frames > 0

## Pauses general animating like moving or executing actions for [param physics_frames].
## Plan processing is still active without being executed. If currently paused, the remaining frames
## will be set to the largest value between the current counter and [param physics_frames].
## Intended for forcing external pauses like hit stun.
func pause_for_frames(physics_frames:int) -> void:
	_pause_frames += physics_frames

func get_component(component_key:StringName) -> Node:
	if components.has(component_key):
		return components[component_key]
	else:
		return null

## Runs the current action's goto again. Can be used for repeat-movement type actions
## like patrols, with the [method GoapAction.action_process] deciding if it should [method replay_goto] again or finish the action.
## Or leave it run indefinitely until the action becomes invalid or the agent gets a new goal.
func replay_goto() -> void:
	# invalidate old pos completely for the goto to start over
	_current_action.goto_pos = -Vector3.INF
	_action_state = ActionState.IDLE

func print_abandonment_issue(reason:PlanAbandonedReasons):
	print(PlanAbandonedReasons.keys()[reason])
