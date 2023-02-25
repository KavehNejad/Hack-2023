extends Node

var set_up_blocks_script = load("res://src/scripts/set_up_block_types.gd").new()

var grid = []

func _ready():
	var shapes = set_up_blocks_script.get_block_tyoes()
	create_grid()
	shapes[1].position.x = 64 * 1 - 32
	shapes[1].position.y = 64 * 4 - 32
	add_child(shapes[1])
	var all_cells = $TileMap.get_used_cells()
	for cell in all_cells:
		grid[cell.y + 1][cell.x + 1] = 1


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
