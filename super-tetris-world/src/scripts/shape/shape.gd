extends Node2D

var block_scene = preload("res://src/scenes/block.tscn")
var defragment_shape_script = load("res://src/scripts/shape/helper_scripts/defragment_shape.gd").new()
var blocks = []
var current = false
var layout = null
var colour

onready var world = get_parent()

signal block_bottom #block touched bottom

var rotations = [0, 90, 180, 270]
var rotation_index = 0

func set_info(shape_info):
	colour = shape_info['colour']
	layout = shape_info['layout']
	world.shapes.append(self)
	var length = len(layout)
	for y in range(len(shape_info['layout'])):
		for x in range(len(shape_info['layout'][y])):
			if shape_info['layout'][y][x] == 1:
				var block = block_scene.instance()
				block.x_in_parent = x
				block.y_in_parent = y
				block.position.x = 64 * x# - int(length/2) * 64
				block.position.y = 64 * y# - int(length/2) * 64
				add_child(block)
				block.get_node("Sprite").modulate = Color(shape_info['colour'])
				blocks.append(block)


func on_game_mode_changed():
	if !current:
		return
	if Global.game_mode == 'Platformer':
		$CanvasLayer/buttons.visible = false
	else:
		$CanvasLayer/buttons.visible = true


func delete():
	$CanvasLayer/buttons.visible = false
	remove_from_grid()
	queue_free()
	world.shapes.erase(self)

func fall_down():
	remove_from_grid()
	position.y += 64
	if overlaps():
		position.y -= 64
		stop_being_current()
	add_to_grid()
	for block in blocks:
		var indexs = world.get_block_index(block.global_position.x, block.global_position.y)
		block.get_node('Label').set_text('x: ' + str(indexs['x']) + ' y: ' + str(indexs['y']))


func stop_being_current():
	$Camera2D.current = false
	$CanvasLayer/buttons.visible = false
	if current:
		emit_signal("block_bottom")
	current = false

func _ready():
	add_to_grid()

func _physics_process(delta):
	if !current:
		return
	if Input.is_action_just_pressed("block_right"):
		move("right")
	if Input.is_action_just_pressed("block_left"):
		move("left")
	if Input.is_action_just_pressed("block_down"):
		move("down")
	if Input.is_action_just_pressed("rotate_block"):
		move("rotate")
	if Input.is_action_just_pressed("discard"):
		discard()


func discard():
	delete()
	world.shapes.erase(self)
	if !current:
		stop_being_current()
		return
	emit_signal("block_bottom")

func move(direction):
	if Global.game_mode == 'Platformer' || !current:
		return
	#checks for stuff every frame
	if direction == 'right':
		remove_from_grid()
		position.x += 64
		if overlaps():
			position.x -= 64
		add_to_grid()
	if direction == 'left':
		remove_from_grid()
		position.x -= 64
		if overlaps():
			position.x += 64
		add_to_grid()
	if direction == 'down':
		fall_down()
	if direction == 'rotate':
		remove_from_grid()
		rotation_index += 1
		if rotation_index > 3:
			rotation_index = 0
		set_rotation(deg2rad(rotations[rotation_index]))
		if overlaps():
			rotation_index -= 1
			if rotation_index < 0:
				rotation_index = 3
			set_rotation(deg2rad(rotations[rotation_index]))
		add_to_grid()

	if position.y > 700:
		emit_signal("block_bottom")
		queue_free()

func _on_touch_screen_left_pressed():
	move('left')

func _on_touch_screen_rotate_pressed():
	move('rotate')

func remove_block(block):
	blocks.erase(block)
	world.remove_block(block.global_position.x, block.global_position.y)
	defragment_shape_script.defragment_shape(self)
	remove_from_grid()
	discard()


func remove_from_grid():
	for block in blocks:
		if is_instance_valid(block):
			world.remove_block(block.global_position.x, block.global_position.y)


func add_to_grid():
	for block in blocks:
		if is_instance_valid(block):
			var indexs = world.add_block(round(block.global_position.x), round(block.global_position.y), block)
			var should_be_pos = world.get_pos_by_index(indexs)


func overlaps():
	for block in blocks:
		if is_instance_valid(block):
			var indexs = world.get_block_index(block.global_position.x, block.global_position.y)
			if world.get_block_by_index(indexs['x'], indexs['y']):
				return true
	return false


func _on_touch_screen_discard_pressed():
	discard()


func _on_touch_screen_down_pressed():
	move('down')

func _on_touch_screen_right_pressed():
	move('right')
