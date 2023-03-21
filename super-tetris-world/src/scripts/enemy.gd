extends KinematicBody2D

export var speed = 50
var gravity = 800

var direction = Vector2.RIGHT
var velocity = Vector2.ZERO
var can_move = true
var falling = false

func _physics_process(delta):
	if !can_move:
		return
	check_if_collides_with_player()
	if !falling:
		check_if_change_direction()
	move(delta)
	check_animation()

func check_if_change_direction():
	if (check_if_wall() || check_if_ledge()):
		direction *= -1
		scale.x *= -1
		
func check_if_wall():
	if (is_on_wall()):
		return is_valid_wall()
	return false

func is_valid_wall():
	for i in range(get_slide_count()):
		var collider = get_slide_collision(i).get_collider()
		if (collider.is_in_group("button")):
			return false
	return true

func check_if_ledge():
	if(not $RayCast2D.is_colliding()):
		return true
	return false
	
func move(delta):
	if !falling:
		velocity = direction * speed
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)

func check_animation():
	if (velocity.y > 0):
		falling = true
		$AnimatedSprite.play("falling")
	else:
		falling = false
		$AnimatedSprite.play("walking")

func check_if_collides_with_player():
	for i in range(get_slide_count()):
		var collider = get_slide_collision(i).get_collider()
		if (collider.is_in_group("player")):
			collider.die()
	return true


func on_paused():
	can_move = false
	$AnimatedSprite.playing = false

func on_unpaused():
	can_move = true
	$AnimatedSprite.playing = true
