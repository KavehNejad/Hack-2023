extends KinematicBody2D

var x_in_parent
var y_in_parent

onready var collision_shape = $CollisionShape2D

func destroy():
	get_parent().remove_block(self)
	queue_free()
