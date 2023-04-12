extends Panel


func _set_current_accessories(
	hat : String, 
	trail : String, 
	flower : String
	) -> void:
	$Vbox/Hats._set_current(hat)
	$Vbox/Trails._set_current(trail)
	$Vbox/Flowers._set_current(flower)
