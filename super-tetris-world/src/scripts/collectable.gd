extends Area2D

onready var world = get_tree().get_nodes_in_group("base_world")[0]
onready var collectable_handler = world.get_node('collectable_handler')

var collected = false

export(bool) var needed = false
export(String) var collectable_name
export(String) var type

func _ready():
	collectable_handler.add_collectable(self)

func _process(delta):
	for body in get_overlapping_bodies():
		if (body.is_in_group('player') && !collected):
			collected = true
			$AudioStreamPlayer2D.play()
			$AnimatedSprite.play("item-collected")


func _item_collected():
	collectable_handler.player_collected_item(self)
	get_parent().remove_child(self)
