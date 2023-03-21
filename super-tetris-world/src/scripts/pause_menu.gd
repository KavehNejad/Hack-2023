extends Control

onready var world = get_tree().get_nodes_in_group("base_world")[0]

func _on_un_pause_button_down():
	world.unpause()

func _on_reset_to_checkpoint_button_down():
	world.revert_to_checkpoint()
	world.unpause()


func _on_move_to_level_select_button_down():
	get_tree().change_scene("res://src/scenes/level_select.tscn")
