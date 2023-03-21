extends Control

onready var level_selector_scene = load("res://src/scenes/level_selector.tscn")


func _ready():
	set_levels()

func level_selected(level):
	get_tree().change_scene("res://src/scenes/levels/" + level.level_src + ".tscn")


func _get_json():
	var file = File.new()
	file.open("res://assets/data/levels.json", file.READ)
	var text = file.get_as_text()
	file.close()
	return parse_json(text)

func set_levels():
	var levels = _get_json()
	var index = 0
	for level_info in levels:
		var level = level_selector_scene.instance()
		level.set_up(level_info)
		level.position.x = 64 * index + 124
		level.position.y = 200
		index += 2
		add_child(level)
