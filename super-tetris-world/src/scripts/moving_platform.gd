extends PathFollow2D

onready var world = get_tree().get_nodes_in_group("base_world")[0]

var speed = 64
var flip = true

var segments = []
var last_segments_positions = []
var positions = []

func _physics_process(delta):
	if flip:
		offset += speed * delta
	else:
		offset -= speed * delta

	if unit_offset == 1 or unit_offset == 0:
		flip = !flip
	_set_positions()
	_add_to_grid()
	_remove_from_grid()
	world._display_level()


func _set_positions():
	last_segments_positions = positions.duplicate()
	positions = []
	for segment in segments:
		var indexs = world.get_block_index(segment.global_position.x + 32, segment.global_position.y + 64)
		positions.append([indexs['x'], indexs['y']])
		var fits = int(int(segment.global_position.x) / 64)
		
		if int(segment.global_position.x) % 64 < 32:
			positions.append([indexs['x'] - 1, indexs['y']])
			
			
			
		if segment.global_position.x - 32 - (fits * 64) > 10:
			positions.append([indexs['x'] + 1, indexs['y']])


func _remove_from_grid():
	for segment_pos in last_segments_positions:
		if !(segment_pos in positions):
			var indexs = world.get_pos_by_index({'x': segment_pos[0], 'y': segment_pos[1]})
			world.remove_block(indexs['x'], indexs['y'])


func _add_to_grid():
	for position in positions:
		var indexs = world.get_pos_by_index({'x': position[0], 'y': position[1]})
		world.add_block(indexs['x'], indexs['y'], 1)
