extends Node3D

@export var speed = 5
@onready var follow = $Path3D/PathFollow3D

# Called when the node enters the scene tree for the first time.
func _ready():
	_generate_curve()


func _generate_curve() -> void:
	var point_number = randi_range(3, 6)
	var points = PackedVector3Array()
	var previous_direction = Vector3(1,0,0)
	var previous_point = Vector3(
		randf_range(-1.0, 1.0),
		0.0,
		randf_range(-1.0, 1.0)
	)
	var index = 0
	for i in point_number + 1:
		if index >= point_number and points.size() > 0:
			print("Looping End")
			points.append(points[0])
			break
		else:
			var random_angle = randf_range(PI / 4, PI / 2)
#			var random_angle = PI / 2
#			if randf() >= 0.5:
#				random_angle *= -1.0
			var direction = previous_direction.rotated(Vector3.UP, random_angle).normalized()
			var distance = randf_range(2, 5)
			var new_point = previous_point + (direction * distance)
			points.append(new_point)
			previous_point = new_point
			previous_direction = direction
			index += 1
	if points.size() > 0:
		var first_point = points[0]
		var last_point = points[points.size() - 2]
		var loop_point_out = Vector3.ZERO
		var curve = Curve3D.new()
		index = 0
		for p in points:
			if index == 0:
				print("Out Only")
				var next_point = points[index + 1]
				var direction_to_next = p.direction_to(next_point)
				var offset_point = direction_to_next
				var direction_to_prev = offset_point.direction_to(last_point)
				loop_point_out = offset_point + (direction_to_prev * -1.0)
				curve.add_point(p, Vector3.ZERO, loop_point_out)
#				print("Adding Start to Curve: ", p, " with out dir: ", loop_point_out)
			elif index == points.size() - 1:
				print("In Only")
				curve.add_point(p, loop_point_out * -1, Vector3.ZERO)
#				print("Adding End to Curve: ", p, " with IN dir: ", loop_point_out * -1)
			else:
				var next_point = points[index + 1]
				var direction_to_next = p.direction_to(next_point)
				var offset_point = direction_to_next
				previous_point = points[index - 1]
				var direction_to_prev = offset_point.direction_to(previous_point)
				var out_point = offset_point + (direction_to_prev * -1.0)
				var in_point = out_point * -1
				curve.add_point(p, in_point, out_point)
#				print("Adding Segment: ", p, " with in: ", in_point, " and out: ", out_point)
			index += 1
		$Path3D.set_curve(curve)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	follow.progress = follow.progress + speed * delta
