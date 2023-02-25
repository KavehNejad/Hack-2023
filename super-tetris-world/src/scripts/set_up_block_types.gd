extends Node

var shape_scene = preload("res://src/scenes/shape.tscn")

func _get_json(file_path):
	var file = File.new()
	file.open(file_path, file.READ)
	var text = file.get_as_text()
	file.close()
	return parse_json(text)

func get_block_tyoes():
	var shape_types = _get_json("res://assets/data/shapes.json")
	var shapes = []
	for shape_info in shape_types:
		var shape = shape_scene.instance()
		shape.set_info(shape_info)
		shapes.append(shape)
	return shapes
