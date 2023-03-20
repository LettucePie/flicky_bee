extends Label


func _ready():
	$Timer.start(1.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var pos = get_position()
	pos = pos.move_toward(Vector2.UP, 2 * $Timer.time_left)
	modulate = Color(1.0, 1.0, 1.0, $Timer.time_left)
	_set_position(pos)


func _on_timer_timeout():
	self.queue_free()
