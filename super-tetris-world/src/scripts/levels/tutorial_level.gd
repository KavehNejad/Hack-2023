extends "res://src/scripts/base_level.gd"

var demo_block_index = -1
var demo_shapes = [
	{
		"layout": [
		  [0, 1, 0],
		  [0, 1, 0],
		  [1, 1, 0]
		],
		"colour": "#00FFFF"
	},
	{
		"layout": [
		  [1, 0, 0],
		  [1, 0, 0],
		  [1, 1, 0]
		],
		 "colour": "#00FFFF"
	},
	{
		"layout": [
		  [0, 1, 0],
		  [0, 1, 0],
		  [0, 1, 0]
		],
		"colour": "#A020F0"
	},
	{
		"layout": [
		  [1, 1, 0],
		  [1, 1, 0]
		],
	"colour": "#FF0000"
	},
	{
		"layout": [
		  [0, 1, 0],
		  [0, 1, 0],
		  [0, 1, 0]
		],
		"colour": "#A020F0"
	},
	{
		"layout": [
		  [0, 1, 0],
		  [0, 1, 0],
		  [0, 1, 0]
		],
		"colour": "#A020F0"
	},
	{
		"layout": [
		  [0, 1, 0],
		  [0, 1, 0],
		  [0, 1, 0]
		],
		"colour": "#A020F0"
	}
]

func _ready():
	var intro_text = load_text("res://assets/text/intro.tres")
	$CanvasLayer/Dialogue.start_speak(intro_text, "long")
	dialogue_displayed = true

func get_next_block():
	demo_block_index += 1
	if demo_block_index >= len(demo_shapes):
		demo_block_index = 0
	return demo_shapes[demo_block_index]

func _process(delta):
	if (dialogue_displayed == true) && (get_node_or_null("Player/Camera2D/CanvasLayer/Dialogue") == null):
		dialogue_removed()

func dialogue_removed():
	dialogue_displayed = false
	$fade_text.play("fade_in_text")


func _on_tutorial_enter_body_entered(body):
	if (!tetris_dialogue_done):
		var dialogue_instance = DIALOGUE.instance()
		dialogue_displayed = true
		$CanvasLayer.add_child(dialogue_instance)
		var text = load_text("res://assets/text/tetris-mechanics-intro.tres")
		dialogue_instance.start_speak(text, "long")
		tetris_dialogue_done = true
