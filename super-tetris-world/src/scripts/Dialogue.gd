extends Node
var current_line = 0
var text = ["", 1]
var current_type = "long"



# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("skip") && Global.is_demo:
		if current_type == "long":
			next()
		elif current_type == "random":
			print("destroying dialogue")
			queue_free()


func start_speak (textInput, type):
	text = textInput
	current_line = 0
	current_type = type
	if current_type == "long":
		speak_long()
	elif current_type == "random":
		speak_random()
	
func speak_long():
	$TextureRect/Text.visible = false
	$TextureRect/Text.text = text[current_line][0]
#	var sound = load("res://assets/sounds/Dialogue/.wav")
	current_line+= 1
	$AnimationPlayer.play("typewriter")
#	$AudioStreamPlayer.stream = sound
	$TextureRect/Text.visible = true
#	$AudioStreamPlayer.play()
	
func speak_random():
	$TextureRect/Text.text = text[0]
#	var sound = load("res://assets/sounds/Dialogue/" + nameSpeaker +"-talk-"+String(text[1]) +".wav")
	$AnimationPlayer.play("typewriter")
#	$AudioStreamPlayer.stream = sound
	$AudioStreamPlayer.play()

func _on_AudioStreamPlayer_finished():
	$AudioStreamPlayer.stop()

func next():
	("next")
	if (current_line < (text.size())):
		speak_long()
	else:
		destroy()

func destroy():
	queue_free()
