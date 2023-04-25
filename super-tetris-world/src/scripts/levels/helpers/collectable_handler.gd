extends Node

signal star_collected

var collectables = []

func reset_collectables_from_checkpoint():
	var array_of_collected_names = Global.collected_collectable_names
	reset_collectables(array_of_collected_names)
	Global.collected_collectable_names = []


func reset_stars_from_save_file(level_name):
	var array_of_collected_names = Global.progress['levels'][level_name]['stars_collected']
	reset_collectables(array_of_collected_names)


func collected_star_names():
	var names = []
	for item in collectables:
		if item.collected and item.type == "Star":
			names.append(item.name)
	return names


func reset_collectables(array_of_collected_names):
	for collectable_name in array_of_collected_names:
		for current_collectable in collectables:
			if current_collectable.name == collectable_name:
				player_collected_item(current_collectable)
				current_collectable.collected = true
				current_collectable.get_parent().remove_child(current_collectable)



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
