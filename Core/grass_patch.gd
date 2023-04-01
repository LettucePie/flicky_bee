extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.has_feature("web"):
		$GrassMulti_L.hide()
		$GrassMulti_R.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
