extends Node

var goodbye = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("fade-in")

func _process(delta):
	if Input.is_action_pressed("skip"):
		$AnimationPlayer.play("fade-out")
		goodbye = true 

func _on_AnimationPlayer_animation_finished(anim_name):
	if (goodbye):
		get_tree().change_scene("res://src/scenes/Tutorial level.tscn")
