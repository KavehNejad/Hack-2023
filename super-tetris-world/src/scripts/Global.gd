extends Node

var game_paused = false
var has_lost = false
var tile_size = 64
var game_mode = 'Platformer' # or Tetris 

func load_next_scene():
	get_tree().change_scene("res://src/scenes/LevelOne.tscn")
