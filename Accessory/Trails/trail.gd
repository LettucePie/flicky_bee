extends Node3D

@export var trails : Array[TrailType] = []

var active_trail = null


func _set_active(trail : String) -> void:
	print("Setting Active Trail: ", trail)
	for t in trails:
		if t.trail_name == trail:
			active_trail = t.scene.instantiate()
			add_child(active_trail)


func _remove_active() -> void:
	if active_trail != null:
		if is_instance_valid(active_trail):
			active_trail.queue_free()
			active_trail = null


func _activate_trail(tf : bool) -> void:
	print("Trail Active : ", tf)
	if active_trail is GPUParticles3D \
	or active_trail is GPUParticles2D:
		active_trail.emitting = tf
