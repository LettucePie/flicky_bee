extends Node3D
class_name BG_Patch

@export var optimize_test : bool = false
@export var has_aux_deco : bool = false
@export var aux_deco_parent : Node3D

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
	if optimize_test:
		$HeavyFoliage.queue_free()
		$LightFoliage.queue_free()
	shuffle_aux_deco()


func shuffle_aux_deco():
	if has_aux_deco:
		var formations : Array = aux_deco_parent.get_children()
		for f in formations:
			f.hide()
		formations.pick_random().show()
