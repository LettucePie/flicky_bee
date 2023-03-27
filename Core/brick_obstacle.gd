extends StaticBody3D


@export var materials : Array[BaseMaterial3D]

# Called when the node enters the scene tree for the first time.
func _ready():
	materials.shuffle()
	$Brick_Mesh.set_surface_override_material(0, materials.front())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
