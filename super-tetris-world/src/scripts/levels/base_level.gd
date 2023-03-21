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
var debug_labels = []
var collectables = {}

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
	player.get_node("Camera2D").current = true

	create_a_checkpoint()
	
	var all_cells = $TileMap.get_used_cells()
	for cell in all_cells:
		var area2d = Area2D.new()
		var shape = RectangleShape2D.new()
		shape.set_extents(Vector2(64,64))
		var collision = CollisionShape2D.new()
		collision.set_shape(shape)

		area2d.position.y = cell.y * 64 + 64 + 32
		area2d.position.x = cell.x * 64
		area2d.add_child(collision)
		add_child(area2d)
		area2d.add_to_group('tetris_collidable')
#		grid[cell.y + 1][cell.x + 1] = 1
#		tile_set_grid[cell.y + 1][cell.x + 1] = 1


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
	current_shape.position.x = int(player.position.x) - int(player.position.x) % 64
	current_shape.position.y = 32
	current_shape.current = true
	current_shape.connect("block_bottom",self, "on_block_touch_bottom")
	connect("game_mode_changed", current_shape, "on_game_mode_changed")


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


func player_collected_item(item):
	collectables[item]['collected'] = true


func add_collectable(item):
	collectables[item] = {
		'collected': false,
		'needed': item.needed
	}


func has_all_needed_collectables():
	for collectable in collectables:
		if collectables[collectable]['needed'] && !collectables[collectable]['collected']:
			return false
	return true


func delete_lines():
	var start_of_line = null
	for y in range(len(grid)):
		for x in range(len(grid[y])):
			if grid[y][x] && is_instance_valid(grid[y][x]) && tile_set_grid[y][x] == 0 && !grid[y][x].get_parent().current:
				if start_of_line && x - start_of_line == 5:
					for i in range(start_of_line, x):
						grid[y][i].destroy()
					
				elif start_of_line == null:
					start_of_line = x
			else:
				start_of_line = null


func _on_touch_screen_switch_mode_pressed():
	switch_game_mode()


func _on_Timer_timeout():
	for shape in shapes:
		shape.fall_down()
	# delete_lines()
