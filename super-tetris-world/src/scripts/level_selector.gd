extends Node2D

var level_src


func _on_TextureButton_button_down():
	get_parent().level_selected(self)


func set_up(info):
	level_src = info['level_src']
	$Label.text = info['level_src']
	$TextureButton.texture_normal = load("res://assets/images/" + info['image_src'])
	$TouchScreenButton.normal = load("res://assets/images/" + info['image_src'])
