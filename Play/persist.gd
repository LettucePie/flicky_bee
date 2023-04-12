extends Node

class_name Persist

## Conceptual
@export var game_ver := 1.0
@export var achievements : Array[String]

var music_vol := 0.8
var sfx_vol := 0.8

var furthest_distance := 0.0
var highest_score := 0
var total_distance := 0.0
var total_score := 0

func _save_game() -> void:
	print("Saving ...")
	var save_dict = {
		"version" = game_ver,
		"music_vol" = music_vol,
		"sfx_vol" = sfx_vol,
		"furthest_distance" = furthest_distance,
		"highest_score" = highest_score,
		"total_distance" = total_distance,
		"total_score" = total_score
	}
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	save_file.store_line(json_string)
	print("Saved!")


func _load_game() -> void:
	print("Loading ...")
	if FileAccess.file_exists("user://savegame.save"):
		var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
		print("Save File Length: ", save_file.get_length())
		while save_file.get_position() < save_file.get_length():
			var json_string = save_file.get_line()
			var json = JSON.new()
			var parse = json.parse(json_string)
			if not parse == OK:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
				continue
			var data = json.get_data()
			if data.has("music_vol"):
				music_vol = data["music_vol"]
			if data.has("sfx_vol"):
				sfx_vol = data["sfx_vol"]
			furthest_distance = data["furthest_distance"]
			highest_score = data["highest_score"]
			total_distance = data["total_distance"]
			total_score = data["total_score"]
		print("Loaded!")
	else:
		print("No File to Load... Creating initial Save")
		_save_game()


func _add_progress(score : int, distance : float) -> void:
	if score > highest_score:
		highest_score = score
	if distance > furthest_distance:
		furthest_distance = distance
	total_score += score
	total_distance += distance
	_save_game()

