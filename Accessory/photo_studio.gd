extends Node3D

@export var filename = "Icon"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Camera_Spin.rotate_y(PI * delta / 2)


func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
			print("Screenshot")
			var image = get_viewport().get_texture().get_image()
			var file = str(Time.get_datetime_string_from_system())
			file = filename + "-" + file + ".png"
			image.save_png("user://studio/" + file)
