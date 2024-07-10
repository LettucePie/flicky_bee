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


func shape_wind_area():
	var north_bodies = $NorthDetection.get_overlapping_bodies()
	var south_bodies = $SouthDetection.get_overlapping_bodies()
	var closest_distance : float = wind_area_shape.size.z / 2
	var north_target : Node3D = north_bodies.front()
	var south_target : Node3D = south_bodies.front()
	if north_bodies.size() > 0:
		for nb in north_bodies:
			if nb.is_in_group("Checkpoint"):
				var distance = self.global_position.distance_to(nb.global_position)
				if distance < closest_distance:
					closest_distance = distance
					north_target = nb
	if south_bodies.size() > 0:
		for sb in south_bodies:
			if sb.is_in_group("Checkpoint"):
				var distance = self.global_position.distance_to(sb.global_position)
				if distance > closest_distance:
					closest_distance = distance
					south_target = sb
	print("Closest Distance for Wind Area is : ", closest_distance)
	print("North Target: ", north_target)
	if north_target != null:
		print("POS: ", north_target.global_position)
	print("South Target: ", south_target)
	if south_target != null:
		print("POS: ", south_target.global_position)
	wind_area_shape.size.z = closest_distance * 2
	if debugging:
		$debug_display.mesh.size.z = closest_distance * 2


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
