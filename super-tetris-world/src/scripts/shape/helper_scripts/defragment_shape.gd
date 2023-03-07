extends Node

var shape_scene = load("res://src/scenes/shape.tscn")

var shape

func defragment_shape(shape_to_defragment):
	shape = shape_to_defragment
	var blocks_to_check = shape.blocks
	var blocks_checked = []
	var sections = []
	for block in blocks_to_check:
		if not (block in blocks_checked):
			sections.append([])
			for connecting_block in connecting_blocks_of_section(block, [], [block]):
				blocks_checked.append(connecting_block)
				sections[-1].append(connecting_block)
			blocks_checked.append(block)

	for section in sections:
		var new_shape = shape_scene.instance()
		var most_left = section[0].global_position.x
		var most_up = section[0].global_position.y
		for block in section:
			if block.global_position.x < most_left:
				most_left = block.global_position.x
			if block.global_position.y < most_up:
				most_up = block.global_position.y

		new_shape.position.x = most_left# + int(len(layout)/2) * 64
		new_shape.position.y = most_up# + int(len(layout)/2) * 64
		var shape_layout = []
		for i in range(3):
			shape_layout.append([])
			for x in range(3):
				shape_layout[-1].append(0)
		for block in section:
			shape_layout[(block.global_position.y - most_up) / 64][(block.global_position.x - most_left) / 64] = 1
		shape.world.add_child(new_shape)
		var colours = ['#A020F0', '#FF0000', '#00FFFF', '#FFFFFF']
		var new_colour = colours[rand_range(0,len(colours))]
		new_shape.set_info({"layout": shape_layout, "colour": new_colour})
		new_shape.add_to_grid()


func connecting_blocks_of_section(block, blocks_checked, blocks_in_section):
	blocks_checked.append(block)
	var connecting_blocks = connecting_blocks_of_shape(block)
	for connecting_block in connecting_blocks:
		if !(connecting_block in blocks_in_section):
			blocks_in_section.append(connecting_block)

	for connecting_block in blocks_in_section:
		if not(connecting_block in blocks_checked):
			return connecting_blocks_of_section(connecting_block, blocks_checked, blocks_in_section)

	return blocks_in_section


func connecting_blocks_of_shape(block):
	var indexs = shape.world.get_block_index(block.global_position.x, block.global_position.y)
	var blocks = []
	
	var indexs_to_check = [
		{'x': indexs['x'] + 1, 'y': indexs['y']},
		{'x': indexs['x'] - 1, 'y': indexs['y']},
		{'x': indexs['x'], 'y': indexs['y'] + 1},
		{'x': indexs['x'], 'y': indexs['y'] - 1}
	]
	for index_to_check in indexs_to_check:
		var connecting_block = shape.world.get_block_by_index(index_to_check['x'], index_to_check['y'])
		if connecting_block && !(typeof(connecting_block) == TYPE_INT) && connecting_block.is_in_group('Block') && connecting_block.get_parent() == shape:
			blocks.append(connecting_block)
	return blocks
