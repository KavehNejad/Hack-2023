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


func get_all_block_positions_without_current_shape():
	var blocks = []
	for shape in shapes:
		if !current_shape == shape:
			blocks += shape.blocks
	var block_positions = []
	for block in blocks:
		block_positions.append(world.get_block_index(
			block.global_position.x, block.global_position.y
		))
	return block_positions


func delete_lines():
	var positions_to_check = get_all_block_positions_without_current_shape()
	var blocks_on_line = {}
	for position in positions_to_check:
		var y = position['y']
		if position['y'] in blocks_on_line.keys():
			blocks_on_line[position['y']].append(position['x'])
		else:
			blocks_on_line[position['y']] = [position['x']]
	
	for line_index in blocks_on_line.keys():
		var x_positions_on_line = blocks_on_line[line_index]
		x_positions_on_line.sort()
		var continuous_blocks = []
		for x_pos in x_positions_on_line:
			if continuous_blocks.size() == 0 or x_pos == continuous_blocks[-1] + 1:
				continuous_blocks.append(x_pos)
			if continuous_blocks.size() > 4:
				for x_pos_to_destroy in continuous_blocks:
					grid[line_index][x_pos_to_destroy].destroy()
				continuous_blocks = []


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
