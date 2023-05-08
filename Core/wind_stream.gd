extends MeshInstance3D

@onready var noise = preload("res://Core/WindStream_Noise.tres")
@export var stream_speed := 6.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var offset = noise.offset
	offset.y += delta * stream_speed
	if offset.y > 2000:
		offset.y = -2000
	noise.offset = offset
