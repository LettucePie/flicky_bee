extends Sprite2D

var child_target := Vector2.ZERO
var child_offset := 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var radian_amount = PI * delta / 2
	self.rotate(radian_amount)
	var child_pos = $Target_Red.position
	var dist = child_pos.distance_squared_to(child_target)
	if dist <= 1.5:
		randomize()
		child_target = Vector2(randf_range(-3.0, 3.0), randf_range(-3.0, 3.0))
		child_offset = randf_range(-0.1, 0.1)
	else:
		child_pos = child_pos.lerp(child_target, delta)
		$Target_Red.position = child_pos
		$Target_Red.rotate(radian_amount + child_offset)
