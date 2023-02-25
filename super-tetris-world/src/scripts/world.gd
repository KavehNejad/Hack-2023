extends Node

var set_up_blocks_script = load("res://src/scripts/set_up_block_types.gd").new()
var shape_scene = preload("res://src/scenes/shape.tscn")

var grid = []
var shapes 
func _ready():
	shapes = set_up_blocks_script.get_block_tyoes()
	create_grid()
	spawn_shape()
	
	var all_cells = $TileMap.get_used_cells()
	for cell in all_cells:
		grid[cell.y + 1][cell.x + 1] = 1
	
func spawn_shape():
	var shape = shape_scene.instance()
	shape.set_info(shapes[rand_range(0,len(shapes))])
	shape.position.x = 64 * 5 - 32
	shape.position.y = 64 * 1 - 32
	add_child(shape)
	shape.connect("block_bottom",self, "on_block_touch_bottom")

func on_block_touch_bottom():
	spawn_shape()

func _process(delta):
	if Input.is_action_just_pressed("game_mode_switch"):
		if Global.game_mode == 'Platformer':
			Global.game_mode = 'Tetris'
		else:
			Global.game_mode = 'Platformer'

func create_grid():
	for y in range(100):
		grid.append([])
		for x in range(100):
			grid[y].append(0)

func get_block_index(x, y):
	return { 'x': round(x / 64), 'y': round(y / 64) }

func get_block_by_index(x, y):
	return grid[y][x]

func add_block(x, y):
	var indexs = get_block_index(x, y)
	grid[indexs['y']][indexs['x']] = 1

func remote_block(x, y):
	var indexs = get_block_index(x, y)
	grid[indexs['y']][indexs['x']] = 0
