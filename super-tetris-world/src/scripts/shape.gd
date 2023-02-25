extends Node2D

var block_scene = preload("res://src/scenes/block.tscn")
var blocks = []
var current = true
var layout = null
signal block_bottom #block touched bottom

func set_info(shape_info):
	layout = shape_info['layout']
	var length = len(layout)
	for y in range(len(shape_info['layout'])):
		for x in range(len(shape_info['layout'][y])):
			if shape_info['layout'][y][x] == 1:
				var block = block_scene.instance()
				block.position.x = 64 * x - int(length/2) * 64
				block.position.y = 64 * y - int(length/2) * 64

				add_child(block)
				blocks.append(block)

func _on_Timer_timeout():
	if Global.game_mode == 'Platformer':
		return
	remove_from_grid()
	position.y += 64
	if overlaps():
		position.y -= 64
		if current:
			emit_signal("block_bottom")

		current = false
	add_to_grid()

func _ready():
	add_to_grid()

func _physics_process(delta):
	if Global.game_mode == 'Platformer' || !current:
		return
	#checks for stuff every frame
	if Input.is_action_just_pressed("block_right"):
		remove_from_grid()
		position.x += 64
		if overlaps():
			position.x -= 64
		add_to_grid()
	if Input.is_action_just_pressed("block_left"):
		remove_from_grid()
		position.x -= 64
		if overlaps():
			position.x += 64
		add_to_grid()
	if Input.is_action_just_pressed("rotate_block"):
		remove_from_grid()
		rotate(deg2rad(90))
		if overlaps():
			rotate(-deg2rad(90))
		add_to_grid()


func remove_from_grid():
	for block in blocks:
		get_parent().remote_block(block.global_position.x, block.global_position.y)

func add_to_grid():
	for block in blocks:
		get_parent().add_block(block.global_position.x, block.global_position.y)

func overlaps():
	for block in blocks:
		var indexs = get_parent().get_block_index(block.global_position.x, block.global_position.y)
		if get_parent().get_block_by_index(indexs['x'], indexs['y']) == 1:
			return true
	return false
