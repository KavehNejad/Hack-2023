extends KinematicBody2D

var gravity
var max_jump_velocity
var min_jump_velocity

signal player_wasted 

var speed = 5 * Global.tile_size
var max_jump_height = 2.25 * Global.tile_size
var min_jump_height = 0.8 * Global.tile_size
var jump_duration = 0.5

var velocity = Vector2.ZERO
var can_kill = true

func _ready():
	gravity = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)

func _physics_process(delta):
	if Global.game_mode == 'Tetris':
		return
	check_if_key_pressed(delta)
	velocity.y += gravity * delta
	move_and_slide(velocity, Vector2.UP)
	for i in get_slide_count():
		if get_slide_collision(i).collider.is_in_group("enemy") && can_kill:
			get_slide_collision(i).collider.queue_free()
			velocity.y = max_jump_velocity
	if is_on_floor():
		can_kill = false
		$Timer.start()
	if position.y > 850:
		die()

func die():
	emit_signal("player_wasted")

func check_if_key_pressed(delta):
	if not Global.has_lost and not Global.game_paused:
		move(delta)

func move(delta):
	velocity.x = 0
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = max_jump_velocity
	if Input.is_action_just_released("jump") and velocity.y < min_jump_velocity:
		velocity.y = min_jump_velocity
	if Input.is_action_pressed("right"):
		velocity.x += speed
	if Input.is_action_pressed("left"):
		velocity.x -= speed


func _on_Timer_timeout():
	can_kill = true
