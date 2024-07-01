extends MeshInstance3D

@export var mat : Material
@export var decay_rate := 1.5

var chase : Node3D
var meshy : ImmediateMesh

var growth := 0.0
var previous_position := Vector3.ZERO
var previous_negative = null
var previous_positive = null
var segments : Array

var disabled := false


func _ready() -> void:
	meshy = ImmediateMesh.new()
	segments.clear()
	meshy.clear_surfaces()
	self.mesh = meshy
	if get_tree().get_nodes_in_group("Player").size() > 0:
		chase = get_tree().get_nodes_in_group("Player").front()
		if chase.has_method("_fly_to"):
			print("Rainbow Trail Found Player")
	else:
		print("Rainbow Trail Failed to Find any Player Nodes")
		chase = get_tree().get_nodes_in_group("PhotoStudio").front()
		if chase != null:
			print("RainbowTrail Found PhotoStudio")
			get_parent().remove_child.call_deferred(self)
			get_window().add_child.call_deferred(self)


func _physics_process(_delta):
	if chase != null:
		if chase.get_position() != previous_position:
			growth += chase.get_position().distance_to(previous_position)
			if growth >= 1:
				if !disabled:
					_grow(chase.get_position())
				growth = 0
				previous_position = chase.get_position()


func _grow(pos : Vector3) -> void:
	var dir_to = previous_position.direction_to(pos)
	var negative_rotated = dir_to.rotated(Vector3.UP, PI * -0.5) * 0.5
	var positive_rotated = dir_to.rotated(Vector3.UP, PI * 0.5) * 0.5
	segments.append([pos + negative_rotated, pos + positive_rotated, pos])


func _process(delta):
	if segments.size() > 1:
		meshy.clear_surfaces()
		meshy.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, mat)
		var clear_segments = []
		for s in segments:
			meshy.surface_set_normal(Vector3.UP)
			meshy.surface_set_uv(Vector2.ZERO)
			meshy.surface_add_vertex(s[0])
			meshy.surface_set_normal(Vector3.UP)
			meshy.surface_set_uv(Vector2.ONE)
			meshy.surface_add_vertex(s[1])
			## Decay
			var rate = clamp(delta * decay_rate, 0.0, 0.5)
			s[0] = s[0].lerp(s[2], rate)
			s[1] = s[1].lerp(s[2], rate)
			if s[0].distance_to(s[2]) < 0.05:
				clear_segments.append(s)
		meshy.surface_end()
		self.mesh = meshy
		if clear_segments.size() > 0:
			for c in clear_segments:
				if segments.has(c):
					segments.erase(c)
			clear_segments.clear()
