extends Node

@export var mat : Material
@export var decay_rate := 1.5

@onready var trace = $Node3D/Trace
@onready var rainbow = $Node3D/Rainbow
var mesh : ImmediateMesh

var growth := 0.0
var previous_position := Vector3.ZERO
var previous_negative = null
var previous_positive = null
var segments : Array


func _ready() -> void:
	mesh = ImmediateMesh.new()
	segments.clear()
	mesh.clear_surfaces()
	rainbow.mesh = mesh


func _input(event):
	if event is InputEventMouseMotion:
		var pos = $Node3D/Camera3D.project_position(event.position, 7)
		trace.position = pos
		growth += event.relative.length()
		if growth >= 50:
			_grow(pos)
			growth = 0


func _grow(pos : Vector3) -> void:
	var dir_to = previous_position.direction_to(pos)
	var negative_rotated = dir_to.rotated(Vector3.UP, PI * -0.5) * 0.5
	var positive_rotated = dir_to.rotated(Vector3.UP, PI * 0.5) * 0.5
	segments.append([pos + negative_rotated, pos + positive_rotated, pos])
	previous_position = pos


func _process(delta):
	if segments.size() > 1:
		mesh.clear_surfaces()
		mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, mat)
		var clear_segments = []
		for s in segments:
			mesh.surface_set_normal(Vector3.UP)
			mesh.surface_set_uv(Vector2.ZERO)
			mesh.surface_add_vertex(s[0])
			mesh.surface_set_normal(Vector3.UP)
			mesh.surface_set_uv(Vector2.ONE)
			mesh.surface_add_vertex(s[1])
			## Decay
			s[0] = s[0].lerp(s[2], delta * decay_rate)
			s[1] = s[1].lerp(s[2], delta * decay_rate)
			if s[0].distance_to(s[2]) < 0.1:
				clear_segments.append(s)
		mesh.surface_end()
		rainbow.mesh = mesh
		if clear_segments.size() > 0:
			for c in clear_segments:
				if segments.has(c):
					segments.erase(c)
			clear_segments.clear()
