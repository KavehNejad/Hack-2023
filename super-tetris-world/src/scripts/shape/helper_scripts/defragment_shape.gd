extends Node

var shape_scene = load("res://src/scenes/shape.tscn")

var shape

func defragment_shape(shape_to_defragment):
	shape = shape_to_defragment
	var sections = get_sections_of_shape()

	for section in sections:
		spawn_shape(section)


func spawn_shape(blocks_in_shape):
	var new_shape = shape_scene.instance()

	set_new_shape_top_left(new_shape, blocks_in_shape)

	var shape_layout = create_new_empty_shape_layout()
	for block in blocks_in_shape:
		shape_layout = add_block_to_shape_layout(shape_layout, block, new_shape)
	shape.world.add_child(new_shape)
	var colours = ['#A020F0', '#FF0000', '#00FFFF', '#FFFFFF']
	var new_colour = colours[rand_range(0,len(colours))]
	new_shape.set_info({"layout": shape_layout, "colour": new_colour})
	new_shape.add_to_grid()


func add_block_to_shape_layout(shape_layout, block, new_shape):
	var x_index = (block.global_position.x - new_shape.position.x) / 64
	var y_index = (block.global_position.y - new_shape.position.y) / 64
	shape_layout[y_index][x_index] = 1
	return shape_layout


func create_new_empty_shape_layout():
	var shape_layout = []
	for i in range(len(shape.layout)):
		shape_layout.append([])
		for x in range(len(shape.layout[0])):
			shape_layout[-1].append(0)
	return shape_layout


func set_new_shape_top_left(new_shape, blocks):
	new_shape.position.x = blocks[0].global_position.x
	new_shape.position.y = blocks[0].global_position.y
	for block in blocks:
		if block.global_position.x < new_shape.position.x:
			new_shape.position.x = block.global_position.x
		if block.global_position.y < new_shape.position.y:
			new_shape.position.y = block.global_position.y


func get_sections_of_shape():
	var blocks_of_shape_checked = []
	var sections = []
	for block in shape.blocks:
		if not (block in blocks_of_shape_checked):
			sections.append([])
			blocks_of_shape_checked.append(block)
			for connecting_block in connecting_blocks_of_section(block, [], [block]):
				blocks_of_shape_checked.append(connecting_block)
				sections[-1].append(connecting_block)
	return sections


func connecting_blocks_of_section(block, blocks_of_section_checked, blocks_in_section):
	blocks_of_section_checked.append(block)
	var connecting_blocks = connecting_blocks_of_shape(block)
	for connecting_block in connecting_blocks:
		if !(connecting_block in blocks_in_section):
			blocks_in_section.append(connecting_block)

	for connecting_block in blocks_in_section:
		if not(connecting_block in blocks_of_section_checked):
			return connecting_blocks_of_section(connecting_block,
				blocks_of_section_checked,
				blocks_in_section)

	return blocks_in_section


func connecting_blocks_of_shape(block):
	var indexs = shape.world.get_block_index(
		block.global_position.x, block.global_position.y
	)
	var blocks = []
	
	var indexs_to_check = [
		{'x': indexs['x'] + 1, 'y': indexs['y']},
		{'x': indexs['x'] - 1, 'y': indexs['y']},
		{'x': indexs['x'], 'y': indexs['y'] + 1},
		{'x': indexs['x'], 'y': indexs['y'] - 1}
	]

	for index_to_check in indexs_to_check:
		var connecting_block = shape.world.get_block_by_index(
			index_to_check['x'], index_to_check['y']
		)
		if is_object_part_of_shape(connecting_block):
			blocks.append(connecting_block)
	return blocks


func is_object_part_of_shape(object):
	return object &&\
		typeof(object) != TYPE_INT &&\
		object.is_in_group('Block') &&\
		object.get_parent() == shape
