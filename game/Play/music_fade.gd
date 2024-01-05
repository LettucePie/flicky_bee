extends AudioStreamPlayer

var fade_out := false
var target := 1.0

func _set_target(t : float) -> void:
	target = t


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_tree().paused:
		target = 0.2
	else:
		target = 1.0
	volume_db = linear_to_db(lerp(db_to_linear(volume_db), target, delta))

