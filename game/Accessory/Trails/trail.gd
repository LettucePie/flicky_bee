extends Node3D

@export var trails : Array[TrailType] = []

var active_trail = null


func _set_active(trail : String) -> void:
	for t in trails:
		if t.trail_name == trail:
			active_trail = t.scene.instantiate()
			if active_trail.is_in_group("CustomTrail"):
				get_window().add_child(active_trail)
			else:
				add_child(active_trail)
	_activate_trail(false)


func _remove_active() -> void:
	if active_trail != null:
		if is_instance_valid(active_trail):
			active_trail.queue_free()
			active_trail = null


func _activate_trail(tf : bool) -> void:
	if active_trail != null:
		if active_trail is GPUParticles3D \
		or active_trail is GPUParticles2D:
			active_trail.emitting = tf
		if active_trail.get_child_count() > 0:
			for c in active_trail.get_children():
				if c is GPUParticles3D \
				or c is GPUParticles2D:
					c.emitting = tf
		if active_trail.is_in_group("CustomTrail"):
			print("CustomTrail Activate: ", tf)
