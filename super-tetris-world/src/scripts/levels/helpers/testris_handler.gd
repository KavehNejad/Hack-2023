extends Node

const SHAPE_SCENE = preload("res://src/scenes/shape.tscn")

onready var world = get_tree().get_nodes_in_group("base_world")[0]

onready var shape_fall_timer = get_node("tetris_timer")

var set_up_blocks_script = load("res://src/scripts/set_up_block_types.gd").new()


var grid = []
var tile_set_grid = []
var shapes_types
var shapes = []
var current_shape


func _ready():
	shapes_types = set_up_blocks_script.get_block_tyoes()
	create_grid()
	var all_cells = world.get_node('map_objects').get_node('TileMap').get_used_cells()
	for cell in all_cells:
		grid[cell.y + 1][cell.x + 1] = 1
		tile_set_grid[cell.y + 1][cell.x + 1] = 1

func _on_tetris_timer_timeout():
	for shape in shapes:
		shape.fall_down()
	delete_lines()
	if world.debug:
		_display_level()


func spawn_shape():
	current_shape = SHAPE_SCENE.instance()
	current_shape.get_node("shape_camera").current = true
	add_child(current_shape)
	current_shape.set_info(get_next_block())
	current_shape.position.x = (64 * world.player_x_index()) - 32
	current_shape.position.y = 32
	current_shape.current = true
	current_shape.connect("block_bottom",self, "on_block_touch_bottom")
	world.connect("game_mode_changed", current_shape, "on_game_mode_changed")


func get_next_block():
	return shapes_types[rand_range(0,len(shapes_types))]


func on_block_touch_bottom():
	spawn_shape()


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


func create_grid():
	for y in range(50):
		grid.append([])
		tile_set_grid.append([])
		for _x in range(10000):
			grid[y].append(null)
			tile_set_grid[y].append(0)


func _display_level():
	if len(world.debug_labels) == 0:
		_create_debug_labels()
	for y in range(20):
		for x in range(50):
			var label = world.debug_labels[y][x]
			var string = "0"
			if world.get_block_by_index(x, y):
				if typeof(world.get_block_by_index(x, y)) == TYPE_INT:
					string = "1"
				else:
					string = "B"
			label.set_text(string)


func _create_debug_labels():
	for y in range(20):
		world.debug_labels.append([])
		for x in range(50):
			var label = Label.new()
			world.debug_labels[y].append(label)
			label.set_position(Vector2(x * 64 - 32, y * 64 - 32))
			world.add_child(label)
