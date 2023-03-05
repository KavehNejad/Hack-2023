extends StaticBody2D

export var button_pressed = false

export(Texture) var button_texture setget set_button_sprite

export var player_triggered = false
export var enemy_triggered = false
export var block_triggered = false

signal button_activated(is_pressed)

func _ready():
	$Sprite.texture = button_texture
	set_sprite_frame(button_pressed)
	set_collision_poligon(button_pressed)
	
func set_button_sprite(this_button_texture):
	button_texture = this_button_texture
	if Engine.editor_hint:
		$Sprite.texture = button_texture

func _on_Area2D_body_entered(body):
	if (player_triggered && body.is_in_group("Player")):
		button_activated()
	if (enemy_triggered && body.is_in_group("enemy")):
		button_activated()
	if (block_triggered && body.is_in_group("Block")):
		button_activated()

func button_activated():
	button_pressed = !button_pressed
	set_sprite_frame(button_pressed)
	set_collision_poligon(button_pressed)
	emit_signal("button_activated", button_pressed)

func set_sprite_frame(is_pressed):
	if (is_pressed):
		$Sprite.frame = 1
	else:
		$Sprite.frame = 0

func set_collision_poligon(is_pressed):
	if (is_pressed):
		$NotPressedCollisionPolygon2D.set_deferred("disabled", true)
		$PressedCollisionPolygon2D.set_deferred("disabled", false)
	else:
		$NotPressedCollisionPolygon2D.set_deferred("disabled", false)
		$PressedCollisionPolygon2D.set_deferred("disabled", true)
