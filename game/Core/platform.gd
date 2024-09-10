extends Area3D


func _ready():
	$Deco.rotation.y = randf_range(0, PI)


func _return_flower() -> Node3D:
	return $Flick_Flower
