extends Node3D

class_name Generator

@export var platform_scene : PackedScene
@export var obstacle_scenes : Array[PackedScene]
#@export var grass_patch_scene : PackedScene
@export var collection_patches : Array[PackedScene]

var platforms : Array
var starting_platform : Node3D
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


func _generate(num : int, z_start : float) -> void:
	if platform_scene != null:
		var z_point = z_start
		var z_previous = z_start
		starting_platform = platform_scene.instantiate()
		starting_platform.set_position(Vector3(0, 0, z_point))
		platforms.append(starting_platform)
		add_child(starting_platform)
		randomize()
		z_point -= randf_range(6.5, 15.5)
		for i in num:
			var new_plat = platform_scene.instantiate()
			new_plat.set_position(
				Vector3(
					randf_range(-5.5, 5.5),
					0,
					z_point
				)
			)
			platforms.append(new_plat)
			add_child(new_plat)
			##
			if abs(z_point) - abs(z_previous) >= 10.0:
				var new_gap = null
				var x_pos = 0.0
				var y_pos = 0.0
				if randf() >= 0.5:
					obstacle_scenes.shuffle()
					new_gap = obstacle_scenes.front().instantiate()
				else:
					x_pos = randf_range(-4.0, 4.0)
					collection_patches.shuffle()
					new_gap = collection_patches.front().instantiate()
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
			##
			z_previous = z_point
			z_point -= randf_range(6.5, 15.5)
		
		z_point = z_start
