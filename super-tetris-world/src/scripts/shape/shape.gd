extends Node2D

signal block_bottom #block touched bottom

onready var world = get_parent()
onready var touchscreen_buttons = get_node("CanvasLayer/buttons")

var block_scene = preload("res://src/scenes/block.tscn")
var detector_scene = preload("res://src/scenes/area_detector.tscn")

var defragment_shape_script = load("res://src/scripts/shape/helper_scripts/defragment_shape.gd").new()
var blocks = []
var current = false
var layout = null
var colour

var rotations = [0, 90, 180, 270]
var rotation_index = 0
var has_been_defragmented = false
var defragment_mutex = Mutex.new()
var detector_shape
var detectors



func set_info(shape_info):
	colour = shape_info['colour']
	layout = shape_info['layout']
	world.shapes.append(self)
	for y in range(len(shape_info['layout'])):
		for x in range(len(shape_info['layout'][y])):
			if shape_info['layout'][y][x] == 1:
				var block = block_scene.instance()
				block.x_in_parent = x
				block.y_in_parent = y
				block.position.x = 64 * x# - int(len(layout)/2) * 64
				block.position.y = 64 * y# - int(len(layout)/2) * 64
				add_child(block)
				block.get_node("Sprite").modulate = Color(shape_info['colour'])
				blocks.append(block)


func on_game_mode_changed():
	if Global.game_mode == 'Platformer':
		touchscreen_buttons.visible = false
	else:
		touchscreen_buttons.visible = true


func delete():
	world.shapes.erase(self)
	if current:
		stop_being_current()
	queue_free()

func fall_down():
	if !current:
		return
	if would_overlap('down'):
		if current:
			stop_being_current()
	else:
		move('down')
	add_indexs_to_blocks()



func add_indexs_to_blocks():
	if !world.debug:
		return

	for block in blocks:
		block.get_node('Label').set_text(str(block.x_in_parent) + "," + str(block.y_in_parent))


func stop_being_current():
	$shape_camera.current = false
	touchscreen_buttons.visible = false
	emit_signal("block_bottom")
	world.disconnect("game_mode_changed", self, "on_game_mode_changed")
	current = false

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


func move(direction, shape = self):
	if Global.game_mode == 'Platformer' || !current:
		return

	if direction == 'right':
		shape.global_position.x += 64
	if direction == 'left':
		shape.global_position.x -= 64
	if direction == 'down':
		shape.global_position.y += 64
	if direction == 'rotate':
		shape.rotate(deg2rad(90))

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
		delete()
	defragment_mutex.unlock()


func would_overlap(direction):
	var detectors_and_shape = spawn_detector_shape()
	var detectors = detectors_and_shape[0]
	var detector_shape = detectors_and_shape[1]
	move(direction, detector_shape)
	for detector in detectors:
		for body in detector.get_overlapping_bodies():
			if body.is_in_group('tetris_collidable') and not body.get_class() == 'detector' and not body in blocks:
				return true

		for area in detector.get_overlapping_areas():
			if area.is_in_group('tetris_collidable'):
				return true
	return false


func spawn_detector_shape():
	if detector_shape == null:
		detector_shape = Area2D.new()
		detectors = []
		for block in blocks:
			var detector = detector_scene.instance()
			detector.position = block.position
			detectors.append(detector)
			detector_shape.add_child(detector)
		add_child(detector_shape)
	else:
		detector_shape.position = Vector2(0,0)
		# detector_shape.rotation = rotation
		print(rad2deg(rotation))
	return [detectors, detector_shape]


func _on_touch_screen_discard_pressed():
	delete()


func _on_touch_screen_down_pressed():
	move('down')

func _on_touch_screen_right_pressed():
	move('right')
