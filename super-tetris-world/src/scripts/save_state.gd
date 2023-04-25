extends Node

var state_file_name = "user://state.save"

func load_state():
	var f = File.new()
	if f.file_exists(state_file_name):
		f.open(state_file_name, File.READ)
		var progress_json_string = f.get_line()
		Global.progress = JSON.parse(progress_json_string).result
		f.close()


func save_state():
	print("saving")
	var f = File.new()
	f.open(state_file_name, File.WRITE)
	f.store_line(JSON.print(Global.progress))
	f.close()

