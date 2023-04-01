extends StaticBody3D


@export var materials : Array[BaseMaterial3D]
@export var materials_low : Array[BaseMaterial3D]

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.has_feature("web") or OS.has_feature("mobile"):
		materials_low.shuffle()
		$Brick_Mesh.set_surface_override_material(0, materials_low.front())
	else:
		materials.shuffle()
		$Brick_Mesh.set_surface_override_material(0, materials.front())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
