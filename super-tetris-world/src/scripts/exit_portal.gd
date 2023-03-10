extends Area2D

onready var world = get_tree().get_nodes_in_group("base_world")[0]

func _process(delta):
	for body in get_overlapping_bodies():
		if body.is_in_group('player'):
			if !world.has_all_needed_collectables():
				return
			Global.load_next_scene()
			queue_free()
	
