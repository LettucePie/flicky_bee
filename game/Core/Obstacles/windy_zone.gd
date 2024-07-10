extends Area3D

## Debug
@export var debugging : bool = false

## Properties
@onready var wind_area_shape : BoxShape3D = $CollisionShape3D.shape

## Settings
@export var playspeed : float = 3.0
@export var gust_curves : Array[Curve]
@onready var gust_curve : Curve = gust_curves.front()
var gust_step_index : int = 0
@export var gust_dir : Vector3 = Vector3.RIGHT
@export var gust_intensity : float = 5.0

## Dynamic
var player : Player = null
var influence : Vector3


func _ready():
	$Timer.wait_time = playspeed
	$Timer.autostart = true
	$Timer.start()
	$debug_display.visible = debugging
	$debug_wind_center.visible = debugging
	call_deferred("shape_wind_area")


func _physics_process(delta):
	influence = gust_dir
	influence *= gust_intensity * gust_curve.sample(inverse_lerp(
		0.0, 
		playspeed, 
		playspeed - $Timer.time_left))
	if player != null:
		print("Push Player by ", influence)
		if player.flicked:
			player.push = influence
			#player.position += influence
	if debugging:
		$debug_wind_center/debug_wind_target.position = influence * 4
	#shape_wind_area()


func shape_wind_area():
	var north_count = $NorthRay.get_collision_count()
	var south_count = $SouthRay.get_collision_count()
	var closest_distance : float = wind_area_shape.size.z / 2
	var north_target : Vector3 = Vector3.ZERO
	var south_target : Vector3 = Vector3.ZERO
	var gpos : Vector3 = self.global_position
	if north_count > 0:
		for ni in north_count:
			if $NorthRay.get_collider(ni).is_in_group("Checkpoint"):
				var target = $NorthRay.get_collision_point(ni)
				if abs(gpos.z - target.z) < closest_distance:
					closest_distance = abs(gpos.z - target.z)
					north_target = target
	if south_count > 0:
		for si in south_count:
			if $SouthRay.get_collider(si).is_in_group("Checkpoint"):
				var target = $SouthRay.get_collision_point(si)
				if abs(gpos.z - target.z) < closest_distance:
					closest_distance = abs(gpos.z - target.z)
					south_target = target
	print("Closest Distance for Wind Area is : ", closest_distance)
	print("North Target: ", north_target, " North Count: ", north_count)
	print("South Target: ", south_target, " South Count: ", south_count)
	wind_area_shape.size.z = closest_distance * 1.9
	if debugging:
		$debug_display.mesh.size.z = closest_distance * 1.9


func queue_next_gust():
	print("Next Gust")
	gust_step_index += 1
	if gust_step_index >= gust_curves.size():
		gust_step_index = 0
	print("Gust set to index: ", gust_step_index)
	gust_curve = gust_curves[gust_step_index]


func _on_body_entered(body):
	if body is Player:
		player = body


func _on_body_exited(body):
	if player != null and body == player:
		print("Player Left Windy Zone")
		player = null


func _on_timer_timeout():
	queue_next_gust()
	$Timer.start()
