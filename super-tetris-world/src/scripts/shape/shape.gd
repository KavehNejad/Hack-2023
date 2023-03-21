extends Node2D

signal block_bottom #block touched bottom

onready var world = get_parent()
onready var touchscreen_buttons = get_node("CanvasLayer/buttons")

var block_scene = preload("res://src/scenes/block.tscn")
var defragment_shape_script = load("res://src/scripts/shape/helper_scripts/defragment_shape.gd").new()
var blocks = []
var current = false
var layout = null
var colour

var rotations = [0, 90, 180, 270]
var rotation_index = 0
var has_been_defragmented = false
var defragment_mutex = Mutex.new()



func set_info(shape_info):
	colour = shape_info['colour']
	layout = shape_info['layout']
	world.shapes.append(self)
	# K and Z are used to handle rotation
	var k = len(layout)
	if k % 2 == 0:
		k -= 1
	var z = len(layout[0])
	if z % 2 == 0:
		z -= 1
	for y in range(len(shape_info['layout'])):
		for x in range(len(shape_info['layout'][y])):
			if shape_info['layout'][y][x] == 1:
				var block = block_scene.instance()
				block.x_in_parent = x
				block.y_in_parent = y
				block.position.x = 64 * x - int(k/2) * 64
				block.position.y = 64 * y - int(z/2) * 64
				add_child(block)
				block.get_node("Sprite").modulate = Color(shape_info['colour'])
				blocks.append(block)


func on_game_mode_changed():
	if Global.game_mode == 'Platformer':
		touchscreen_buttons.visible = false
	else:
		touchscreen_buttons.visible = true


func delete():
	remove_from_grid()
	world.shapes.erase(self)
	if current:
		stop_being_current()
	queue_free()

func fall_down():
	remove_from_grid()
	position.y += 64
	if overlaps():
		position.y -= 64
		if current:
			stop_being_current()
		if _in_no_place_zone():
			delete()
	add_to_grid()
	add_indexs_to_blocks()


func _in_no_place_zone():
	for block in blocks:
		for area in block.get_node('Area2D').get_overlapping_areas():
			if 'no_place_zone' in area.get_groups():
				return true
	return false

func add_indexs_to_blocks():
	if !world.debug:
		return

	for block in blocks:
		var indexs = world.get_block_index(block.global_position.x, block.global_position.y)
		block.get_node('Label').set_text('x: ' + str(indexs['x']) + ' y: ' + str(indexs['y']))


func stop_being_current():
	$shape_camera.current = false
	touchscreen_buttons.visible = false
	emit_signal("block_bottom")
	world.disconnect("game_mode_changed", self, "on_game_mode_changed")
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
		delete()


func move(direction):
	if Global.game_mode == 'Platformer' || !current:
		return

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

	if position.y > 600:
		delete()

func _on_touch_screen_left_pressed():
	move('left')

func _on_touch_screen_rotate_pressed():
	move('rotate')


func remove_block(block):
	defragment_mutex.lock()
	if !has_been_defragmented:
		has_been_defragmented = true

		blocks.erase(block)
		world.remove_block(block.global_position.x, block.global_position.y)
		defragment_shape_script.defragment_shape(self)
		remove_from_grid()
		delete()
	defragment_mutex.unlock()


func remove_from_grid():
	for block in blocks:
		if is_instance_valid(block):
			world.remove_block(block.global_position.x, block.global_position.y)


func add_to_grid():
	for block in blocks:
		if is_instance_valid(block):
			world.add_block(round(block.global_position.x), round(block.global_position.y), block)


func overlaps():
	for block in blocks:
		if is_instance_valid(block):
			var indexs = world.get_block_index(block.global_position.x, block.global_position.y)
			if indexs['x'] < 0 or indexs['y'] < 0:
				return true
			if world.get_block_by_index(indexs['x'], indexs['y']):
				return true
	return false


func _on_touch_screen_discard_pressed():
	delete()


func _on_touch_screen_down_pressed():
	move('down')

func _on_touch_screen_right_pressed():
	move('right')
