@tool
extends PanelContainer

@onready var name_label: Label = $MarginContainer/VBoxContainer/Name
@onready var state: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/State
@onready var goal: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Goal
@onready var plan: VBoxContainer = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Plan
@onready var world_state: Label = $MarginContainer/VBoxContainer/HBoxContainer/WorldState

var agent_id:int

func set_agent_name(s:String):
	name_label.text = s

func set_state(s:String):
	state.text = "State: " + s

func set_goal(s:String):
	goal.text = "Goal: " + s

func set_world_state(s:String):
	world_state.text = s

func set_plan(actions:Array[String], highlight_index:int):
	for child in plan.get_children():
		child.queue_free()
	
	for a in actions:
		var label := Label.new()
		label.text = a
		plan.add_child(label)
	
	#print("blue ", highlight_index)
	var child:Label = plan.get_child(highlight_index)
	#print(child)
	child.add_theme_color_override("font_color", Color.DEEP_SKY_BLUE)
