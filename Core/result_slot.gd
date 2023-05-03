extends Control

@export var label_path : NodePath
var label : Label
var start_value := 0
var target_value := 1

var grow := false
var start_time : int
var target_time : int

func _grow_to(val : int) -> void:
	start_value = 0
	target_value = val
	self.show()
	if label_path != null:
		label = get_node(label_path)
		start_time = Time.get_ticks_msec()
		var modifier = 800
		if val > 40:
			modifier += 400
		if val > 100:
			modifier += 400
		target_time = start_time + modifier
		grow = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if grow:
		var current = Time.get_ticks_msec()
		var percent = inverse_lerp(
			start_time, target_time, current
		)
		if percent > 1.0:
			percent = 1.0
			grow = false
		label.text = str(
			round(
				lerp(start_value, target_value, percent)
			)
		)
