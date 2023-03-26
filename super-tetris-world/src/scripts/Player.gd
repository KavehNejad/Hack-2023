extends KinematicBody2D

onready var world = get_tree().get_nodes_in_group("base_world")[0]

var gravity
var max_jump_velocity
var min_jump_velocity

signal player_died

var speed = 5 * Global.tile_size
var max_jump_height = 2.25 * Global.tile_size
var min_jump_height = 0.8 * Global.tile_size
var jump_duration = 0.5

var velocity = Vector2.ZERO
var can_kill = true
var can_move = true

var move_right_button_pressed = false
var move_left_button_pressed = false

func _ready():
	gravity = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)

func _physics_process(delta):
	if !(Global.game_mode == 'Tetris') and can_move:
		_handle_movement(delta)
	
	handle_death_by_block()


func _handle_movement(delta):
	velocity.x = 0
	check_if_key_pressed(delta)
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	handle_collisions()
#	handle_floor_bug()
	check_if_fell_in_abyss()
	handle_animations()


func handle_death_by_block():
	for body in $Area2D.get_overlapping_bodies():
		if 'block' in body.get_groups() and body.get_parent() != world.current_shape:
			die()

func handle_collisions():
	for i in get_slide_count():
		handle_enemy_collision(i)

func die():
	emit_signal("player_died")

func check_if_key_pressed(delta):
	if not Global.has_lost and not Global.game_paused:
		handle_keyboard_movement(delta)

func handle_animations():
	if (velocity.x == 0):
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0
		$AnimatedSprite.play("walking")
	if (velocity.y < 0):
		$AnimatedSprite.play("jump")

func handle_keyboard_movement(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		move('up')
	if Input.is_action_just_released("jump") and velocity.y < min_jump_velocity:
		move('min_up')
	if Input.is_action_pressed("right") || move_right_button_pressed:
		move('right')
	if Input.is_action_pressed("left") || move_left_button_pressed:
		move('left')

func on_game_mode_changed():
	if Global.game_mode == 'Platformer':
		$CanvasLayer/buttons.visible = true
	else:
		$CanvasLayer/buttons.visible = false

func move(direction):
	if !can_move:
		return

	if direction == 'up':
		velocity.y = max_jump_velocity
	if direction == 'min_up':
		velocity.y = min_jump_velocity
	if direction == 'right':
		velocity.x += speed
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.play("walking")
	if direction == 'left':
		velocity.x -= speed
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.play("walking")


func _on_Timer_timeout():
	can_kill = true


func _on_touch_screen_right_released():
	move_right_button_pressed = false


func _on_touch_screen_right_pressed():
	move_right_button_pressed = true


func _on_touch_screen_left_pressed():
	move_left_button_pressed = true


func _on_touch_screen_left_released():
	move_left_button_pressed = false


func _on_touch_screen_up_pressed():
	if is_on_floor():
		move('up')


func on_paused():
	if Global.game_mode == 'Platformer':
		$CanvasLayer/buttons.visible = false
	can_move = false

func on_unpaused():
	if Global.game_mode == 'Platformer':
		$CanvasLayer/buttons.visible = true
	can_move = true
	

func handle_enemy_collision(i):
	if get_slide_collision(i).collider.is_in_group("enemy") && can_kill:
		print(velocity.y)
		if (velocity.y > 0):
			get_slide_collision(i).collider.queue_free()
			yield(get_slide_collision(i).collider, "tree_exited")
			velocity.y = max_jump_velocity
		else:
			die()

func check_if_fell_in_abyss():
	if position.y > 850:
		die()

func handle_floor_bug():
	if is_on_floor():
		can_kill = false
		$Timer.start()
