extends ColorRect

signal queue_timeout()

func _queue() -> void:
	print("QUEUE displaying for up to 10 seconds")
	$Timer.start(10)
	self.show()


func _stop() -> void:
	$Timer.stop()
	self.hide()


func _on_timer_timeout():
	print("QUEUE Timeout")
	$Timer.stop()
	self.hide()
	emit_signal("queue_timeout")
