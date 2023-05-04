extends Node3D

@export var trails : Array[TrailType] = []

var active_trail = null


func _set_active(trail : String) -> void:
	print("Setting Active Trail: ", trail)
	for t in trails:
		if t.trail_name == trail:
			print(trail, " Trail Found")
			active_trail = t.scene.instantiate()
			add_child(active_trail)
	_activate_trail(false)


func _remove_active() -> void:
	if active_trail != null:
		if is_instance_valid(active_trail):
			active_trail.queue_free()
			active_trail = null


func _activate_trail(tf : bool) -> void:
	if active_trail != null:
		print("Trail Active : ", tf)
		if active_trail is GPUParticles3D \
		or active_trail is GPUParticles2D:
			active_trail.emitting = tf
		if active_trail.get_child_count() > 0:
			for c in active_trail.get_children():
				if c is GPUParticles3D \
				or c is GPUParticles2D:
					c.emitting = tf
