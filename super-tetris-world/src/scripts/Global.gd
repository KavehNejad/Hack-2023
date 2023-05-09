extends Node

var game_paused = false
var has_lost = false
var tile_size = 64
var game_mode = 'Platformer' # or Tetris 
var is_demo = false
var player_checkpoint_pos
var collected_collectable_names = []
var used_checkpoint_names = []
var music_volume = 50

var progress = {
	"levels": {},
	"music_volume": music_volume
}
