extends Node

func _get_json(file_path):
	var file = File.new()
	file.open(file_path, file.READ)
	var text = file.get_as_text()
	file.close()
	return parse_json(text)

func get_block_tyoes(json = "res://assets/data/shapes.json"):
	var shape_types = _get_json(json)
	var shapes = []
	for shape_info in shape_types:
		shapes.append(shape_info)
	return shapes
