extends Area2D

func _process(delta):
	for body in get_overlapping_bodies():
		if body.is_in_group('Player'):
			body.die()
		if body.is_in_group('block'):
			body.destroy()
	
