extends AudioStreamPlayer

@export var library : Array[AudioStreamWAV] = []

var queue := -1

func _ready():
	if get_parent().has_signal("button_down"):
		get_parent().button_down.connect(play)


func _set_sound(index : int) -> void:
	if playing:
		queue = index
	else:
		stream = library[index]


func _on_finished():
	if queue >= 0:
		stream = library[queue]
		queue = -1
