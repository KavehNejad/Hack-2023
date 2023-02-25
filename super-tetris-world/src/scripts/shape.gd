extends Node2D

var block_scene = preload("res://src/scenes/block.tscn")
var blocks = []
var current = true

func set_info(shape_info):
	for y in range(len(shape_info['layout'])):
		for x in range(len(shape_info['layout'][y])):
			if shape_info['layout'][y][x] == 1:
				var block = block_scene.instance()
				block.position.x = 64 * x
				block.position.y = 64 * y
				add_child(block)
				blocks.append(block)

func _on_Timer_timeout():
	remote_from_grid()
	position.y += 64
	if overlaps():
		position.y -= 64
		current = true

func _ready():
	add_to_grid()

func _physics_process(delta):
	if !current:
		return
	#checks for stuff every frame
	if Input.is_action_just_pressed("block_right"):
		remote_from_grid()
		position.x += 64
		if overlaps():
			position.x -= 64
		add_to_grid()
	if Input.is_action_just_pressed("block_left"):
		remote_from_grid()
		position.x -= 64
		if overlaps():
			position.x += 64
		add_to_grid()

func remote_from_grid():
	for block in blocks:
		get_parent().remote_block(position.x + block.position.x, position.y + block.position.y)

func add_to_grid():
	for block in blocks:
		get_parent().add_block(position.x + block.position.x, position.y + block.position.y)

func overlaps():
	for block in blocks:
		var indexs = get_parent().get_block_index(position.x + block.position.x, position.y + block.position.y)
		if get_parent().get_block_by_index(indexs['x'], indexs['y']) == 1:
			return true
	return false
