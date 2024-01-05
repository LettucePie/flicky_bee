extends Node

@export var mat : Material

@onready var trace = $Node3D/Trace
@onready var rainbow = $Node3D/Rainbow
var mesh : ImmediateMesh

var growth := 0.0
var previous_position := Vector3.ZERO
var previous_negative = null
var previous_positive = null


func _ready() -> void:
	mesh = ImmediateMesh.new()
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
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, mat)
	##
	## Directional Vector Stuff
	##
	var dir_to = previous_position.direction_to(pos)
	var negative_rotated = dir_to.rotated(Vector3.UP, PI * -0.5) * 0.5
	var positive_rotated = dir_to.rotated(Vector3.UP, PI * 0.5) * 0.5
	var negative_position = previous_position + negative_rotated
	var positive_position = previous_position + positive_rotated
	if previous_negative != null:
		negative_position = previous_negative
		positive_position = previous_positive
	previous_negative = pos + negative_rotated
	previous_positive = pos + positive_rotated
	##
	## Bottom Left
	## Tri 1
	## V0
	##
	mesh.surface_set_normal(Vector3.UP)
	mesh.surface_set_uv(Vector2.ZERO)
	mesh.surface_add_vertex(negative_position)
	##
	## Bottom Right
	## Tri 1
	## V1
	##
	mesh.surface_set_normal(Vector3.UP)
	mesh.surface_set_uv(Vector2.ZERO)
	mesh.surface_add_vertex(positive_position)
	##
	## Top Left
	## Tri 1
	## V2
	##
	mesh.surface_set_normal(Vector3.UP)
	mesh.surface_set_uv(Vector2.ZERO)
	mesh.surface_add_vertex(pos + negative_rotated)
	##
	## Top Left
	## Tri 2
	## V2
	##
	mesh.surface_set_normal(Vector3.UP)
	mesh.surface_set_uv(Vector2.ZERO)
	mesh.surface_add_vertex(pos + negative_rotated)
	##
	## Bottom Right
	## Tri 2
	## V1
	##
	mesh.surface_set_normal(Vector3.UP)
	mesh.surface_set_uv(Vector2.ZERO)
	mesh.surface_add_vertex(positive_position)
	##
	## Top Right
	## Tri 2
	## V3
	##
	mesh.surface_set_normal(Vector3.UP)
	mesh.surface_set_uv(Vector2.ZERO)
	mesh.surface_add_vertex(pos + positive_rotated)
	##
	mesh.surface_end()
	rainbow.mesh = mesh
	previous_position = pos


func _process(delta):
	pass
