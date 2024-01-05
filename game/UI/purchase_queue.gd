extends ColorRect

signal queue_timeout()

var quips = [
	"How's the weather?",
	"Taking a bit...",
	"Ya like bees?",
	"Mmm awkward"
]

func _queue() -> void:
	print("QUEUE displaying for up to 30 seconds")
	$Timer.start(30)
	$Panel/Label.text = "Processing..."
	self.show()
	$MessagePanel.hide()


func _extend(t : float) -> void:
	$Timer.start(t)
	$Panel/Label.text = quips.pick_random()


func _stop() -> void:
	$Timer.stop()
	self.hide()


func _on_timer_timeout():
	print("QUEUE Timeout")
	$Timer.stop()
	self.hide()
	emit_signal("queue_timeout")
	

func _set_status_message(status : String, message : String) -> void:
	$MessagePanel/Status.text = status
	$MessagePanel/Message.text = message


func _show_message() -> void:
	$MessagePanel.show()
	$Timer.stop()


func _on_done_pressed():
	_stop()
