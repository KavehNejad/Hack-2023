extends KinematicBody2D


func _ready():
	get_parent().segments.append(self)
