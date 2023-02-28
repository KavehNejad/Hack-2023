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

func _on_Timer_timeout():
	fall_down()

func fall_down():
	if Global.game_mode == 'Platformer':
		return
	remove_from_grid()
	position.y += 64
	if overlaps():
		position.y -= 64
		if current:
			$CanvasLayer/buttons.visible = false
			emit_signal("block_bottom")


		current = false
	add_to_grid()

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
	if !current:
		return
	emit_signal("block_bottom")
	delete()

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
		rotate(deg2rad(90))
		if overlaps():
			rotate(-deg2rad(90))
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

func remove_from_grid():
	for block in blocks:
		if is_instance_valid(block):
			get_parent().remove_block(block.global_position.x, block.global_position.y)

func add_to_grid():
	for block in blocks:
		if is_instance_valid(block):
			get_parent().add_block(block.global_position.x, block.global_position.y, block)

func overlaps():
	for block in blocks:
		if is_instance_valid(block):
			var indexs = get_parent().get_block_index(block.global_position.x, block.global_position.y)
			if get_parent().get_block_by_index(indexs['x'], indexs['y']):
				return true
	return false


func _on_touch_screen_discard_pressed():
	discard()


func _on_touch_screen_down_pressed():
	move('down')

func _on_touch_screen_right_pressed():
	move('right')
