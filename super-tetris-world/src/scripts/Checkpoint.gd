extends Area2D

func _process(delta):
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group('Player'):
			print("IN")
			get_parent().create_a_checkpoint()
	
