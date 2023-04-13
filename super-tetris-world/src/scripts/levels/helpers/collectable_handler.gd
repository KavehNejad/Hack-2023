extends Node

signal star_collected

var collectables = []

func reset_collectables_from_checkpoint():
	for collectable_name in Global.collected_collectable_names:
		for current_collectable in collectables:
			if current_collectable.name == collectable_name:
				player_collected_item(current_collectable)
				current_collectable.collected = true
				current_collectable.get_parent().remove_child(current_collectable)
	Global.collected_collectable_names = []


func player_collected_item(item):
	handle_star_collecting(item)


func handle_star_collecting(item):
	if (item.type == "Star"):
		emit_signal("star_collected")


func has_all_needed_collectables():
	for collectable in collectables:
		if collectable.needed && !collectable.collected:
			return false
	return true


func create_checkpoint():
	var collected_item_names = []
	for collectable in collectables:
		if collectable.collected:
			collected_item_names.append(collectable.name)
	Global.collected_collectable_names = collected_item_names


func add_collectable(item):
	collectables.append(item)
