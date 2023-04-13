extends Area2D

export(String) var checkpoint_name

var used = false

func _ready():
	$AnimatedSprite.play("still-pole")


func _process(delta):
	if used:
		return
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group('player'):
			Global.used_checkpoint_names.append(checkpoint_name)
			raise_flag()
			get_parent().create_a_checkpoint()


func raise_flag():
	used = true
	$AnimatedSprite.play("pole-going-up")
