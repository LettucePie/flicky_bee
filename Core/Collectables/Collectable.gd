extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Idle")
	$AnimationPlayer.speed_scale = randf_range(0.6, 0.9)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
