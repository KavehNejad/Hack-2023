extends Area2D


func _process(delta):
	for body in get_overlapping_bodies():
		if body.is_in_group('Player'):
			get_parent().has_flag = true
			queue_free()
	

