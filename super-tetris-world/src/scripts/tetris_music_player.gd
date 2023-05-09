extends AudioStreamPlayer2D


func _ready():
	_set_volume()

func _set_volume():
	volume_db = Global.music_volume - 70


func _on_base_world_volume_changed():
	_set_volume()
