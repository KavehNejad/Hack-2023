extends Area2D

onready var world = get_tree().get_nodes_in_group("base_world")[0]

export(bool) var needed = false

func _ready():
	world.add_collectable(self)

func _process(delta):
	for body in get_overlapping_bodies():
		if body.is_in_group('player'):
			get_parent().player_collected_item(self)
			queue_free()
