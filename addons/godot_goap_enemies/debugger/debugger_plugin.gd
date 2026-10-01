@tool
extends EditorDebuggerPlugin

const DEBUGGER_UI_SCENE = preload("res://addons/godot_goap_enemies/debugger/goap_debugger_ui.tscn")

var debugger_ui:Control

func _has_capture(capture: String) -> bool:
	return capture.begins_with("goap")

func _capture(message: String, data: Array, session_id: int) -> bool:
	if message == "goap:create_agent":
		debugger_ui.new_agent(data[0])
	elif not debugger_ui.agent_uis.has(data[0]):
		return true
	else:
		match message:
			"goap:clear_agent":
				debugger_ui.clear_agent(data[0])
			"goap:set_agent_name":
				debugger_ui.get_agent(data[0]).set_agent_name(data[1])
			"goap:set_state":
				debugger_ui.get_agent(data[0]).set_state(data[1])
			"goap:set_goal":
				debugger_ui.get_agent(data[0]).set_goal(data[1])
			"goap:set_action":
				debugger_ui.get_agent(data[0]).set_action(data[1])
			"goap:set_world_state":
				debugger_ui.get_agent(data[0]).set_world_state(data[1])
			"goap:set_plan":
				debugger_ui.get_agent(data[0]).set_plan(data[1], data[2])
		
	return true

func _setup_session(session_id) -> void:
	var session := get_session(session_id)
	
	debugger_ui = DEBUGGER_UI_SCENE.instantiate()
	session.add_session_tab(debugger_ui)
	session.stopped.connect(_on_session_stopped.bind(session_id))
	session.set_meta("__goap_debugger_ui", debugger_ui)

func _on_session_stopped(_session_id):
	debugger_ui.clear()
