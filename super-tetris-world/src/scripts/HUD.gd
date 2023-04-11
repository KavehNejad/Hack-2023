extends CanvasLayer

var stars_collected = 0
export var max_stars = 3

func _ready():
	$StarsFull.visible = false


func _on_star_collected():
	if (stars_collected == 0):
		$StarsFull.visible = true
		$StarsFull.rect_size.x = 320
		stars_collected = 1
	elif (stars_collected == max_stars):
		pass
	else:
		$StarsFull.rect_size.x += 320
		stars_collected += 1
