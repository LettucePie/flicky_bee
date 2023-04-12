extends Node3D

@export var speed = 5
@onready var follow = $Path3D/PathFollow3D

# Called when the node enters the scene tree for the first time.
func _ready():
	_generate_curve()
	$Path3D/PathFollow3D/Dragonfly/AnimationPlayer.play("Wings")


func _generate_curve() -> void:
	randomize()
	var point_number = randi_range(3, 6)
	var radial_step = (PI * 2) / point_number
	var points = PackedVector3Array()
	var direction = Vector3(1,0,0)
	direction = direction.rotated(Vector3.UP, randf_range(0.0, PI))
	var center = Vector3(
		randf_range(-2.5, 2.5),
		0.0,
		randf_range(-0.5, 0.5)
	)
	var index = 0
	for i in point_number + 1:
		if index >= point_number and points.size() > 0:
#			print("Looping End")
			points.append(points[0])
			break
		else:
			direction = direction.rotated(Vector3.UP, radial_step)
			var new_point = center + (direction * randf_range(1.5, 3.5))
			points.append(new_point)
			index += 1
	if points.size() > 0:
		var first_point = points[0]
		var last_point = points[points.size() - 2]
		var loop_point_out = Vector3.ZERO
		var curve = Curve3D.new()
		index = 0
		for p in points:
			if index == 0:
#				print("Out Only")
				var next_point = points[index + 1]
				var next_normal = p.direction_to(next_point)
				var prev_normal = p.direction_to(last_point)
				var angle = clamp(
					next_normal.signed_angle_to(prev_normal, Vector3.UP),
					PI * -0.2,
					PI * 0.2
					)
				var offset_normal = next_normal.rotated(Vector3.UP, angle * - 1)
				var offset_distance = p.distance_to(next_point) * 0.15
				curve.add_point(p, Vector3.ZERO, offset_normal * offset_distance)
			elif index == points.size() - 1:
#				print("In Only")
				var next_point = points[1]
				var next_normal = p.direction_to(next_point)
				var prev_normal = p.direction_to(last_point)
				var angle = clamp(
					next_normal.signed_angle_to(prev_normal, Vector3.UP),
					PI * -0.2,
					PI * 0.2
					)
				var offset_normal = prev_normal.rotated(Vector3.UP, angle)
				var offset_distance = p.distance_to(last_point) * 0.15
				curve.add_point(p, offset_normal * offset_distance, Vector3.ZERO)
			else:
				var next_point = points[index + 1]
				var prev_point = points[index - 1]
				var next_normal = p.direction_to(next_point)
				var prev_normal = p.direction_to(prev_point)
				var angle = clamp(
					next_normal.signed_angle_to(prev_normal, Vector3.UP),
					PI * -0.2,
					PI * 0.2
					)
				var in_normal = prev_normal.rotated(Vector3.UP, angle)
				var in_distance = p.distance_to(prev_point) * 0.15
				var out_normal = next_normal.rotated(Vector3.UP, angle * - 1)
				var out_distance = p.distance_to(next_point) * 0.15
				var in_point = in_normal * in_distance
				var out_point = out_normal * out_distance
				curve.add_point(p, in_point, out_point)
			index += 1
		$Path3D.set_curve(curve)


func _physics_process(delta):
	follow.progress = follow.progress + speed * delta


func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		print("Dragonfly encountered Player")
		if body.has_method("_hit"):
			body._hit()


func _on_area_3d_body_exited(body):
	pass # Replace with function body.
