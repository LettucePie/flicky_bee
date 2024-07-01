extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.has_feature("web"):
		$GrassMulti_L.hide()
		$GrassMulti_R.hide()
	if get_window().has_node("Persist"):
		var clutter = get_window().get_node("Persist").clutter
		if clutter:
			$HeavyFoliage.show()
			$LightFoliage.queue_free()
		else:
			$HeavyFoliage.queue_free()
			$LightFoliage.show()
