extends Node

onready var tetris_handler = get_node('tetris_handler')
onready var collectable_handler = get_node('collectable_handler')

signal game_mode_changed
signal paused
signal unpaused

export(bool) var is_last = false
export(bool) var debug = false


const DIALOGUE = preload("res://src/scenes/Dialogue.tscn")

onready var player = get_node('Player')

var paused = false
var has_flag = false
var tetris_dialogue_done = false
var player_checkpoint_position 
var dialog_is_open = false


var debug_labels = []

var dialogue_displayed = false


func load_text(path):
	var file = File.new()
	file.open(path, File.READ)
	var textString = file.get_as_text()
	file.close()
	var textArray= str2var(textString)
	return textArray


func pause():
	paused = true
	emit_signal("paused")
	$CanvasLayer/pause_menu.visible = true
	$CanvasLayer/open_pause_menu_touchscreen_button.visible = false


func unpause():
	paused = false
	emit_signal("unpaused")
	$CanvasLayer/pause_menu.visible = false
	$CanvasLayer/open_pause_menu_touchscreen_button.visible = true


func toggle_pause():
	if dialog_is_open:
		return
	if paused:
		unpause()
	else:
		pause()


func _ready():
	connect_pause_signals()
	connect("game_mode_changed", player, "on_game_mode_changed")
	if is_last:
		return
	Global.game_mode = 'Platformer'
	
	_reset_values_from_checkpoint()

	VisualServer.set_default_clear_color(Color("#2596be"))
	player.connect("player_died", self, 'on_player_died')
	player.get_node("Camera2D").current = true

	create_a_checkpoint()


func _reset_values_from_checkpoint():
	if !Global.player_checkpoint_pos:
		return

	player.position = Global.player_checkpoint_pos
	
	collectable_handler.reset_collectables_from_checkpoint()

	Global.player_checkpoint_pos = null


func connect_pause_signals():
	for node in get_tree().get_nodes_in_group("needs_to_stop_when_dialogue"):
		connect("paused", node, "on_paused")
		connect("unpaused", node, "on_unpaused")


func connect_dialogue_signals(dialogue):
	dialogue.connect("dialog_opened", self, "on_dialog_oppened")
	dialogue.connect("dialog_clossed", self, "on_dialog_clossed")
	for node in get_tree().get_nodes_in_group("needs_to_stop_when_dialogue"):
		dialogue.connect("dialog_opened", node, "on_paused")
		dialogue.connect("dialog_clossed", node, "on_unpaused")


func on_dialog_oppened():
	dialog_is_open = true
	tetris_handler.shape_fall_timer.stop()
	$CanvasLayer/open_pause_menu_touchscreen_button.visible = false


func on_dialog_clossed():
	dialog_is_open = false
	tetris_handler.shape_fall_timer.start()
	$CanvasLayer/open_pause_menu_touchscreen_button.visible = true


func on_player_died(): 
	revert_to_checkpoint()


func revert_to_checkpoint():
	Global.player_checkpoint_pos = player_checkpoint_position
	get_tree().reload_current_scene()


func create_a_checkpoint():
	player_checkpoint_position = player.position
	collectable_handler.create_checkpoint()


func player_x_index():
	return get_block_index(player.position.x, 0)['x']


func _process(delta):
	if is_last:
		return
	
	if Input.is_action_just_pressed("game_mode_switch"):
		switch_game_mode()
	
	if Input.is_action_just_pressed("pause"):
		toggle_pause()


func switch_game_mode():
	if dialog_is_open:
		return
	if Global.game_mode == 'Platformer':
		Global.game_mode = 'Tetris'
		player.get_node("Camera2D").current = false
		tetris_handler.spawn_shape()
		toggle_node_visibility_tetris_mode(false)
		$AudioStreamPlayer2D.play()
		VisualServer.set_default_clear_color(Color("#000000"))
	else:
		VisualServer.set_default_clear_color(Color("#2596be"))
		Global.game_mode = 'Platformer'
		player.get_node("Camera2D").current = true
		$AudioStreamPlayer2D.stop()
		toggle_node_visibility_tetris_mode(true)
		tetris_handler.current_shape.disconnect("block_bottom", tetris_handler, "on_block_touch_bottom")
		tetris_handler.current_shape.delete()
		tetris_handler.current_shape = null
	emit_signal("game_mode_changed")


func toggle_node_visibility_tetris_mode(is_visible):
	for node in get_tree().get_nodes_in_group("invisible_in_tetris_mode"):
		node.visible = is_visible


func get_block_index(x, y):
	return { 'x': round(x / 64), 'y': round(y / 64) }


func get_block_by_index(x, y):
	return tetris_handler.grid[y][x]


func add_block(x, y, block):
	var indexs = get_block_index(x, y)
	tetris_handler.grid[indexs['y']][indexs['x']] = block
	return indexs


func get_pos_by_index(indexs):
	return { 'x': indexs['x'] * 64, 'y': indexs['y'] * 64}


func remove_block(x, y, block = null):
	var indexs = get_block_index(x, y)
	if block == null or tetris_handler.grid[indexs['y']][indexs['x']] == block:
		tetris_handler.grid[indexs['y']][indexs['x']] = null


func _on_touch_screen_switch_mode_pressed():
	switch_game_mode()


func _on_open_pause_menu_touchscreen_button_pressed():
	pause()
