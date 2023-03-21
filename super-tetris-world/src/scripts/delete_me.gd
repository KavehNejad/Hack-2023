extends Area2D

var overlapping = []

func _process(delta):
	overlapping = get_overlapping_areas()


func get_class(): return "detector"
