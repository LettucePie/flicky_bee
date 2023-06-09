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
	if hats.size() > 0:
		for h in hats:
			if h.hat_name == hat:
				active_hat = h.scene.instantiate()
				self.add_child(active_hat)


func _set_big_mode(tf : bool) -> void:
	big_mode = tf
	set_scale(Vector3.ONE)
	if big_mode:
		set_scale(Vector3.ONE * 2)
