extends Control

@export var color_wheel : Array[Color] = []
@export var shift_mod := 5.0
var current_index = 0
var shift := false


func _ready():
	if color_wheel.size() == 0:
		color_wheel.append(Color.WHITE)
		color_wheel.append(Color.RED)


func _physics_process(delta):
	if shift:
		modulate = modulate.lerp(color_wheel[current_index], delta * shift_mod)
		if modulate == color_wheel[current_index]:
			current_index += 1
			if current_index >= color_wheel.size():
				current_index = 0



func _on_visibility_changed():
	shift = visible
