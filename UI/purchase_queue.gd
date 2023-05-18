extends ColorRect

signal queue_timeout()

func _queue() -> void:
	$Timer.start(10)
	self.show()


func _stop() -> void:
	$Timer.stop()
	self.hide()


func _on_timer_timeout():
	$Timer.stop()
	self.hide()
	emit_signal("queue_timeout")
