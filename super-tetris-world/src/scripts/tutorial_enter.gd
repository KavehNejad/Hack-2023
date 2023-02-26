extends Area2D

var done = false


func _process(delta):
	if done:
		return
	for body in get_overlapping_bodies():
		if body.is_in_group('Player'):
			get_parent().next_text()
			done = true
