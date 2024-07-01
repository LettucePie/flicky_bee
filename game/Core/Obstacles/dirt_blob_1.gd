extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.has_feature("web"):
		$Node3D/MultiMeshInstance3D.hide()
	if get_window().has_node("Persist"):
		$Node3D/MultiMeshInstance3D.visible = get_window().get_node("Persist").clutter
