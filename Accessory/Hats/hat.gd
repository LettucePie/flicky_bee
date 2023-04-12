extends Node3D


@export var hats : Array[HatType] = []

var active_hat = null
var big_mode := false


func _ready():
	_remove_hat()


func _remove_hat() -> void:
	if active_hat != null and is_instance_valid(active_hat):
		active_hat.queue_free()
		active_hat = null


func _set_active(hat : String) -> void:
	print("Setting Active Hat: ", hat)
	if hats.size() > 0:
		for h in hats:
			if h.hat_name == hat:
				print("Found Hat")
				active_hat = h.scene.instance()
				self.add_child(active_hat)


func _set_big_mode(tf : bool) -> void:
	print("Setting Hat Big_Mode: ", tf)
	big_mode = tf
