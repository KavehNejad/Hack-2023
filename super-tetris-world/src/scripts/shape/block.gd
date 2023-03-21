extends KinematicBody2D

var x_in_parent
var y_in_parent

onready var colision_area = $block_collision_shape

func destroy():
	get_parent().remove_block(self)
	queue_free()
