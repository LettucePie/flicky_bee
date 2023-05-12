extends Node3D


@onready var turn = $Turn

@onready var modif = randf_range(1.2, 1.4)
@onready var dir = [-1, 1].pick_random()


func _physics_process(delta):
	turn.rotate_y(PI * ((delta * modif) * dir))
