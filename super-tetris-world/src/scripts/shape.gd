extends Node2D

var block_scene = preload("res://src/scenes/block.tscn")
var shape_scene = load("res://src/scenes/shape.tscn")
var blocks = []
var current = false
var layout = null
var colour
signal block_bottom #block touched bottom

var rotations = [0, 90, 180, 270]
var rotation_index = 0

func set_info(shape_info):
	colour = shape_info['colour']
	layout = shape_info['layout']
	get_parent().shapes.append(self)
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
	get_parent().shapes.erase(self)

func fall_down():
	remove_from_grid()
	position.y += 64
	if overlaps():
		position.y -= 64
		stop_being_current()
	add_to_grid()
	for block in blocks:
		var indexs = get_parent().get_block_index(block.global_position.x, block.global_position.y)
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
	get_parent().shapes.erase(self)
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
	get_parent().remove_block(block.global_position.x, block.global_position.y)
	split_into_shapes()
	remove_from_grid()
	discard()


func split_into_shapes():
	var blocks_to_check = blocks
	var blocks_checked = []
	var sections = []
	for block in blocks_to_check:
		if not (block in blocks_checked):
			sections.append([])
			for connecting_block in connecting_blocks_of_section(block, [], [block]):
				blocks_checked.append(connecting_block)
				sections[-1].append(connecting_block)
			blocks_checked.append(block)

	for section in sections:
		var new_shape = shape_scene.instance()
		var most_left = section[0].global_position.x
		var most_up = section[0].global_position.y
		for block in section:
			if block.global_position.x < most_left:
				most_left = block.global_position.x
			if block.global_position.y < most_up:
				most_up = block.global_position.y

		new_shape.position.x = most_left# + int(len(layout)/2) * 64
		new_shape.position.y = most_up# + int(len(layout)/2) * 64
		var shape_layout = []
		for i in range(3):
			shape_layout.append([])
			for x in range(3):
				shape_layout[-1].append(0)
		for block in section:
			shape_layout[(block.global_position.y - most_up) / 64][(block.global_position.x - most_left) / 64] = 1
		get_parent().add_child(new_shape)
		var colours = ['#A020F0', '#FF0000', '#00FFFF', '#FFFFFF']
		var new_colour = colours[rand_range(0,len(colours))]
		new_shape.set_info({"layout": shape_layout, "colour": new_colour})
		new_shape.add_to_grid()


func connecting_blocks_of_section(block, blocks_checked, blocks_in_section):
	blocks_checked.append(block)
	var connecting_blocks = connecting_blocks_of_shape(block)
	for connecting_block in connecting_blocks:
		if !(connecting_block in blocks_in_section):
			blocks_in_section.append(connecting_block)

	for connecting_block in blocks_in_section:
		if not(connecting_block in blocks_checked):
			return connecting_blocks_of_section(connecting_block, blocks_checked, blocks_in_section)

	return blocks_in_section


func connecting_blocks_of_shape(block):
	var indexs = get_parent().get_block_index(block.global_position.x, block.global_position.y)
	var blocks = []
	
	var indexs_to_check = [
		{'x': indexs['x'] + 1, 'y': indexs['y']},
		{'x': indexs['x'] - 1, 'y': indexs['y']},
		{'x': indexs['x'], 'y': indexs['y'] + 1},
		{'x': indexs['x'], 'y': indexs['y'] - 1}
	]
	for index_to_check in indexs_to_check:
		var connecting_block = get_parent().get_block_by_index(index_to_check['x'], index_to_check['y'])
		if connecting_block && !(typeof(connecting_block) == TYPE_INT) && connecting_block.is_in_group('Block') && connecting_block.get_parent() == self:
			blocks.append(connecting_block)
	return blocks


func remove_from_grid():
	for block in blocks:
		if is_instance_valid(block):
			get_parent().remove_block(block.global_position.x, block.global_position.y)


func add_to_grid():
	for block in blocks:
		if is_instance_valid(block):
			var indexs = get_parent().add_block(round(block.global_position.x), round(block.global_position.y), block)
			var should_be_pos = get_parent().get_pos_by_index(indexs)
#			block.global_position.x = should_be_pos['x']
#			block.global_position.y = should_be_pos['y']

#	if len(blocks) > 0:
#		print(blocks[0].global_position.x)
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
