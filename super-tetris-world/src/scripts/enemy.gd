extends KinematicBody2D

var move_right = true
export(int) var speed = 1

func _process(delta):
	var velocity = Vector2()
	if move_right:
		velocity.x -= speed
		$AnimatedSprite.flip_h = false
	else:
		velocity.x += speed
		$AnimatedSprite.flip_h = true
	var colision = move_and_collide(velocity)
	
	if colision:
		if colision.collider.name == "Player":
			colision.collider.die()
		move_right = !move_right

