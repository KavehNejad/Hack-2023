extends Area2D

func _ready():
	$AnimatedSprite.play("still-pole")

func _process(delta):
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group('Player'):
			$AnimatedSprite.play("pole-going-up")
			get_parent().create_a_checkpoint()
	
