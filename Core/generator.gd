extends Node3D

class_name Generator

##
## Testing
##
@export var gen_start : PackedScene
@export var gen_end : PackedScene
##
@export var difficulty_curve : Curve
@export var max_difficulty := 16.0
@export var platform_scene : PackedScene
@export var windhook_scene : PackedScene
@export var obstacle_scenes : Array[PackedScene]
@export var danger_scenes : Array[PackedScene]
#@export var grass_patch_scene : PackedScene
@export var collection_patches : Array[PackedScene]

var platforms : Array
var starting_platform : Node3D
var flower := "default"
#var grass_patches : Array
var gaps : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _clear_platforms() -> void:
	if platforms.size() > 0:
		for p in platforms:
			if is_instance_valid(p):
				p.queue_free()
	platforms.clear()
	platforms.resize(0)
	if gaps.size() > 0:
		for g in gaps:
			if is_instance_valid(g):
				g.queue_free()
	gaps.clear()
	gaps.resize(0)


func _clear_gaps(point) -> void:
	var stray_gaps : Array
	if gaps.size() > 0:
		for g in gaps:
			var pos = g.get_position()
			if pos.z < point:
				stray_gaps.append(g)
	if stray_gaps.size() > 0:
		for sg in stray_gaps:
			gaps.erase(sg)
			if is_instance_valid(sg):
				sg.queue_free()
	stray_gaps.clear()


func _generate(num : int, z_start : float, flower : String) -> void:
	if platform_scene != null:
		var z_point = z_start
		var z_previous = z_start
		if platforms.size() == 0:
			starting_platform = platform_scene.instantiate()
			starting_platform.set_position(Vector3(0, 0, z_point))
			platforms.append(starting_platform)
			add_child(starting_platform)
			starting_platform._return_flower()._assign_flower(flower)
		randomize()
		var difficulty_progress = difficulty_curve.sample(
			inverse_lerp(0, 1000, abs(z_point))
		)
		var difficulty_skew = clamp(
			lerp(0.0, max_difficulty, difficulty_progress),
			0.0,
			max_difficulty
		)
		z_point -= randf_range(6.5, 6.5 + difficulty_skew)
		var start = gen_start.instantiate()
		start.position.z = z_point
		add_child(start)
		for i in num:
			var new_plat = platform_scene.instantiate()
			new_plat.set_position(
				Vector3(
					randf_range(-5.5, 5.5),
					0,
					z_point
				)
			)
			add_child(new_plat)
			platforms.append(new_plat)
			new_plat._return_flower()._assign_flower(flower)
			##
			if abs(z_point) - abs(z_previous) >= 8.5:
				var new_gap = null
				var bonus_gap = null
				var x_pos = 0.0
				var y_pos = 0.0
				if randf() >= 0.5:
					randomize()
					if randf() >= 0.5:
						danger_scenes.shuffle()
						new_gap = danger_scenes.front().instantiate()
					else:
						obstacle_scenes.shuffle()
						new_gap = obstacle_scenes.front().instantiate()
				else:
					x_pos = randf_range(-4.0, 4.0)
					collection_patches.shuffle()
					new_gap = collection_patches.front().instantiate()
					var danger_difficulty = clamp(
						difficulty_progress,
						0.08,
						0.9
					)
					randomize()
					if randf() <= danger_difficulty:
						danger_scenes.shuffle()
						bonus_gap = danger_scenes.front().instantiate()
				if new_gap != null:
					new_gap.set_position(
						Vector3(
							x_pos,
							y_pos,
							lerp(z_previous, z_point, 0.5)
						)
					)
					gaps.append(new_gap)
					add_child(new_gap)
					if bonus_gap != null:
						bonus_gap.set_position(
							Vector3(
								0,
								0,
								lerp(z_previous, z_point, 0.5)
							)
						)
						gaps.append(bonus_gap)
						add_child(bonus_gap)
			##
			z_previous = z_point
			if i < (num - 1):
				z_point -= randf_range(6.5, 6.5 + difficulty_skew)
		var end = gen_end.instantiate()
		end.position.z = z_point
		add_child(end)
		z_point = z_start
