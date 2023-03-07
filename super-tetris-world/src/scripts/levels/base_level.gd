extends Node

signal game_mode_changed


export(bool) var is_last = false
export(bool) var debug = false


const DIALOGUE = preload("res://src/scenes/Dialogue.tscn")
const SHAPE_SCENE = preload("res://src/scenes/shape.tscn")

onready var player = get_node('Player')
onready var shape_fall_timer = get_node("Timer")

var set_up_blocks_script = load("res://src/scripts/set_up_block_types.gd").new()

var has_flag = false
var tetris_dialogue_done = false
var player_checkpoint_position 
var dialog_is_open = false

var grid = []
var tile_set_grid = []
var shapes_types
var shapes = []
var current_shape

var dialogue_displayed = false


func load_text(path):
	var file = File.new()
	file.open(path, File.READ)
	var textString = file.get_as_text()
	file.close()
	var textArray= str2var(textString)
	return textArray


func _ready():
	connect("game_mode_changed", player, "on_game_mode_changed")
	if is_last:
		return

	VisualServer.set_default_clear_color(Color("#2596be"))
	player.connect("player_died", self, 'on_player_died')
	shapes_types = set_up_blocks_script.get_block_tyoes()
	create_grid()
	player.get_node("Camera2D").current = true

	create_a_checkpoint()
	
	var all_cells = $TileMap.get_used_cells()
	for cell in all_cells:
		grid[cell.y + 1][cell.x + 1] = 1
		tile_set_grid[cell.y + 1][cell.x + 1] = 1


func connect_dialogue_signals(dialogue):
	dialogue.connect("dialog_opened", self, "on_dialog_oppened")
	dialogue.connect("dialog_clossed", self, "on_dialog_clossed")
	for node in get_tree().get_nodes_in_group("needs_to_stop_when_dialogue"):
		dialogue.connect("dialog_opened", node, "on_dialog_oppened")
		dialogue.connect("dialog_clossed", node, "on_dialog_clossed")


func on_dialog_oppened():
	dialog_is_open = true
	shape_fall_timer.stop()


func on_dialog_clossed():
	dialog_is_open = false
	shape_fall_timer.start()


func on_player_died(): 
	revert_to_checkpoint()

func revert_to_checkpoint():
	player.position = player_checkpoint_position

func create_a_checkpoint():
	player_checkpoint_position = player.position

func spawn_shape():
	current_shape = SHAPE_SCENE.instance()
	current_shape.get_node("shape_camera").current = true
	add_child(current_shape)
	current_shape.set_info(get_next_block())
	current_shape.position.x = (64 * player_x_index()) - 32
	current_shape.position.y = 32
	current_shape.current = true
	current_shape.connect("block_bottom",self, "on_block_touch_bottom")
	connect("game_mode_changed", current_shape, "on_game_mode_changed")


func player_x_index():
	return get_block_index(player.position.x, 0)['x']

func get_next_block():
	return shapes_types[rand_range(0,len(shapes_types))]

func on_block_touch_bottom():
	spawn_shape()

func _process(delta):
	if is_last:
		return
	
	if Input.is_action_just_pressed("game_mode_switch"):
		switch_game_mode()

func switch_game_mode():
	if dialog_is_open:
		return
	if Global.game_mode == 'Platformer':
		Global.game_mode = 'Tetris'
		player.get_node("Camera2D").current = false
		spawn_shape()
		$AudioStreamPlayer2D.play()
		VisualServer.set_default_clear_color(Color("#000000"))
	else:
		Global.game_mode = 'Platformer'
		player.get_node("Camera2D").current = true
		$AudioStreamPlayer2D.stop()
		VisualServer.set_default_clear_color(Color("#2596be"))
		current_shape.disconnect("block_bottom",self, "on_block_touch_bottom")
		current_shape.delete()
		current_shape = null
	emit_signal("game_mode_changed")


func delete_lines():
	var start_of_line = null
	for y in range(len(grid)):
		for x in range(len(grid[y])):
			if grid[y][x] && is_instance_valid(grid[y][x]) && tile_set_grid[y][x] == 0 && !grid[y][x].get_parent().current:
				if start_of_line && x - start_of_line == 5:
					for i in range(start_of_line, x):
						print_level()
						grid[y][i].destroy()
					
				elif start_of_line == null:
					start_of_line = x
			else:
				start_of_line = null


func create_grid():
	for y in range(50):
		grid.append([])
		tile_set_grid.append([])
		for _x in range(10000):
			grid[y].append(null)
			tile_set_grid[y].append(0)


func get_block_index(x, y):
	return { 'x': round(x / 64), 'y': round(y / 64) }

func get_block_by_index(x, y):
	return grid[y][x]

func add_block(x, y, block):
	var indexs = get_block_index(x, y)
	grid[indexs['y']][indexs['x']] = block
	return indexs


func get_pos_by_index(indexs):
	return { 'x': indexs['x'] * 64, 'y': indexs['y'] * 64}

func remove_block(x, y):
	var indexs = get_block_index(x, y)
	grid[indexs['y']][indexs['x']] = null


func _on_touch_screen_switch_mode_pressed():
	switch_game_mode()


func print_level():
	for y in range(6, 11):
		print(grid[y])
	print("\n\n===========================\n\n")


func _on_Timer_timeout():
	for shape in shapes:
		shape.fall_down()
	delete_lines()
