extends Area3D

@export var debugging : bool = false

@export var playspeed : float = 3.0
@export var gust_curves : Array[Curve]
@onready var gust_curve : Curve = gust_curves.front()
var gust_step_index : int = 0
@export var gust_dir : Vector3 = Vector3.RIGHT
@export var gust_intensity : float = 0.25
var player : Player = null

var influence : Vector3


func _ready():
	$Timer.wait_time = playspeed
	$Timer.autostart = true
	$Timer.start()
	$debug_display.visible = debugging
	$debug_wind_center.visible = debugging


func _physics_process(delta):
	influence = gust_dir
	influence *= gust_intensity * gust_curve.sample(inverse_lerp(
		0.0, 
		playspeed, 
		playspeed - $Timer.time_left))
	if player != null:
		print("Push Player by ", influence)
		if player.flicked:
			player.position += influence
	if debugging:
		$debug_wind_center/debug_wind_target.position = influence * 4


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
		player = null


func _on_timer_timeout():
	queue_next_gust()
	$Timer.start()
