extends Node

class_name Persist

@export var game_ver := 1.0
const keys = [
	"version",
	"music_vol",
	"sfx_vol",
	"furthest_distance",
	"highest_score",
	"total_distance",
	"total_score",
	"honey_points",
	"accessories",
	"achievements",
	"hat",
	"trail", 
	"flower"]

var music_vol := 0.8
var sfx_vol := 0.8

var furthest_distance := 0.0
var highest_score := 0
var total_distance := 0.0
var total_score := 0

var honey_points := 0
var accessories : PackedStringArray
var achievements : PackedStringArray

var hat := "default"
var trail := "default"
var flower := "default"


func _save_game() -> void:
	print("Saving ...")
	var save_dict = {
		"version" = game_ver,
		"music_vol" = music_vol,
		"sfx_vol" = sfx_vol,
		"furthest_distance" = furthest_distance,
		"highest_score" = highest_score,
		"total_distance" = total_distance,
		"total_score" = total_score,
		"honey_points" = honey_points,
		"accessories" = accessories,
		"achievements" = achievements,
		"hat" = hat,
		"trail" = trail,
		"flower" = flower
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
		var valid = true
		while save_file.get_position() < save_file.get_length():
			var json_string = save_file.get_line()
			var json = JSON.new()
			var parse = json.parse(json_string)
			if not parse == OK:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
				continue
			var data = json.get_data()
			if data.has("version"):
				if data["version"] < game_ver:
					valid = false
			for k in keys:
				if !data.has(k):
					valid = false
			if valid:
				music_vol = data["music_vol"]
				sfx_vol = data["sfx_vol"]
				furthest_distance = data["furthest_distance"]
				highest_score = data["highest_score"]
				total_distance = data["total_distance"]
				total_score = data["total_score"]
				honey_points = data["honey_points"]
				accessories = data["accessories"]
				achievements = data["achievements"]
				hat = data["hat"]
				trail = data["trail"]
				flower = data["flower"]
				print("Loaded!")
			else:
				print("Save File is missing Data Keys")
				_file_surgery(data)
	else:
		print("No File to Load... Creating initial Save")
		_save_game()


func _file_surgery(data) -> void:
	print("Performing File Surgery")
	if data.has("music_vol"):
		music_vol = data["music_vol"]
	if data.has("sfx_vol"):
		sfx_vol = data["sfx_vol"]
	if data.has("furthest_distance"):
		furthest_distance = data["furthest_distance"]
	if data.has("highest_score"):
		highest_score = data["highest_score"]
	if data.has("total_distance"):
		total_distance = data["total_distance"]
	if data.has("total_score"):
		total_score = data["total_score"]
	if data.has("honey_points"):
		honey_points = data["honey_points"]
	if data.has("accessories"):
		accessories = data["accessories"]
	if data.has("achivements"):
		achievements = data["achievements"]
	if data.has("hat"):
		hat = data["hat"]
	if data.has("trail"):
		trail = data["trail"]
	if data.has("flower"):
		flower = data["flower"]
	print("File Surgery Complete, saving to rebuild")
	_save_game()


func _register_scores(score : int, distance : float) -> void:
	if score > highest_score:
		highest_score = score
	if distance > furthest_distance:
		furthest_distance = distance
	_save_game()


func _add_scores(score : int, distance : float) -> void:
	total_score += score
	total_distance += distance
	_save_game()


func _add_points(points : int) -> void:
	honey_points += points


func _spend_points(points : int) -> void:
	honey_points = clamp(
		honey_points - points, 0, honey_points
	)


func _add_accessory(acc : String) -> void:
	if !accessories.has(acc):
		accessories.append(acc)
		_save_game()
