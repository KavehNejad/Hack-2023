extends Node

var set_up_blocks_script = load("res://src/scripts/set_up_block_types.gd").new()

func _ready():
	var shapes = set_up_blocks_script.get_block_tyoes()
	add_child(shapes[1])
	shapes[1].position.x = 200
	shapes[1].position.y = 200
