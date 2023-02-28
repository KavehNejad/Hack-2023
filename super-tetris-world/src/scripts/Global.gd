extends Node

var game_paused = false
var has_lost = false
var tile_size = 64
var game_mode = 'Platformer' # or Tetris 
var levels = ["Tutorial", "LevelOne", "LevelTwo", "LevelThree"]
var level_index = 0
var is_demo = false

func load_next_scene():
	level_index += 1
	var level = levels[level_index]
	get_tree().change_scene("res://src/scenes/levels/" + level + ".tscn")
