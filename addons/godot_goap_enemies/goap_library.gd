class_name GoapLibrary

enum Distance {MELEE, CLOSE, FAR, INFINITE}
enum Awareness {NONE, LOW, HIGH}

const goals_library = {
	"be_safe": preload("res://goals/be_safe.gd"),
	"kill_target": preload("res://goals/kill_target.gd"),
	"patrol": preload("res://goals/patrol.gd")
}

const actions_library = {
	"move_to_cover": preload("res://actions/move_to_cover.gd"),
	"build_cover": preload("res://actions/build_cover.gd"),
	"get_axe": preload("uid://drm6ak1vjr7n4"),
	"patrol": preload("uid://bwflu83eidkhx"),
	"follow_target": preload("res://actions/follow_target.gd"),
	"shoot_target": preload("res://actions/shoot_target.gd")
}
