extends Node

@export var filename := "Screenshot"
@export var enabled := false

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE and enabled:
			print("Screenshot")
			var image = get_viewport().get_texture().get_image()
			var file = str(Time.get_datetime_string_from_system())
			file = filename + "-" + file + ".png"
			image.save_png("user://studio/" + file)
