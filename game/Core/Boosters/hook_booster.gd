extends Node3D

@export var x_randomize := false

# Called when the node enters the scene tree for the first time.
func _ready():
	if x_randomize:
		position.x = randf_range(-4.0, 4.0)
