@tool
extends EditorPlugin 

const GoapDebuggerPlugin := preload("res://addons/godot_goap_enemies/debugger/debugger_plugin.gd")

var _debugger_plugin: EditorDebuggerPlugin

func _enter_tree() -> void:
	_debugger_plugin = GoapDebuggerPlugin.new()
	add_debugger_plugin(_debugger_plugin)

func _exit_tree() -> void:
	remove_debugger_plugin(_debugger_plugin)


func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass
