@tool
extends Control

const AGENT_UI_SCENE = preload("res://addons/godot_goap_enemies/debugger/agent_display.tscn")

@onready var main_container: HBoxContainer = $MarginContainer/VBoxContainer/MainContainer

var agent_uis:Dictionary[int, Control]

func new_agent(id:int):
	var ui := AGENT_UI_SCENE.instantiate()
	ui.agent_id = id
	agent_uis[id] = ui
	add_child(ui)

func clear_agent(id:int):
	agent_uis[id].queue_free()
	agent_uis.erase(id)

func get_agent(id:int) -> Control:
	return agent_uis[id]

func clear():
	for agent in agent_uis:
		clear_agent(agent)
