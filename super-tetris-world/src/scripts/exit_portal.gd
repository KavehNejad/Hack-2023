extends Area2D

export(bool) var needs_flag = false

func _process(delta):
	for body in get_overlapping_bodies():
		if body.is_in_group('Player'):
			if needs_flag && !get_parent().has_flag:
				return
			Global.load_next_scene()
	
