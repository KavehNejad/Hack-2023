extends Node2D

var block_scene = preload("res://src/scenes/block.tscn")

func set_info(shape_info):
	for y in range(len(shape_info['layout'])):
		for x in range(len(shape_info['layout'][y])):
			if shape_info['layout'][y][x] == 1:
				var block = block_scene.instance()
				block.position.x = 64 * x
				block.position.y = 64 * y
				add_child(block)



func _on_Timer_timeout():
	print(1)
