extends Timer
class_name WindZoneManager

## Physics Influence Settings
var playspeed : float = 3.0
@onready var gust_curves : Array[Curve] = [
	preload("res://Core/Obstacles/gust_curves/gust_curve_A.tres"),
	preload("res://Core/Obstacles/gust_curves/gust_curve_D.tres"),
	preload("res://Core/Obstacles/gust_curves/gust_curve_B.tres"),
	preload("res://Core/Obstacles/gust_curves/gust_curve_D.tres"),
	preload("res://Core/Obstacles/gust_curves/gust_curve_C.tres"),
	preload("res://Core/Obstacles/gust_curves/gust_curve_D.tres")
]
@onready var gust_curve : Curve = gust_curves.front()
var gust_step_index : int = 0
var gust_dir : Vector3 = Vector3.RIGHT
var gust_intensity : float = 5.0

## WindShader visual Settings
@onready var wind_zone_noise : FastNoiseLite = \
	preload("res://Core/Art/Materials/WindZone_Noise.tres")
@onready var wind_zone_mask_grad : Gradient = \
	preload("res://Core/Art/Textures/WindZone_Shader_MaskGrad.tres")
var shader_speed_min : float = 20.0
var shader_speed_max : float = 55.0
var color_target_left : Color
var color_target_right : Color

## Dynamic
var influence : Vector3 = Vector3.ZERO


func _ready():
	timeout.connect(_on_timer_timeout)
	wait_time = playspeed
	autostart = true
	start()


func _physics_process(delta):
	influence = gust_dir
	var curve_percent : float = gust_curve.sample(inverse_lerp(
		0.0, 
		playspeed, 
		playspeed - time_left))
	influence *= gust_intensity * curve_percent
	##
	var offset : Vector3 = wind_zone_noise.offset
	offset.y += delta * lerp(shader_speed_min, shader_speed_max, curve_percent)
	if offset.y > 2000:
		offset.y = -2000
	wind_zone_noise.offset = offset
	color_target_left = Color.WHITE.lerp(Color.BLACK, curve_percent)
	color_target_right = color_target_left
	wind_zone_mask_grad.colors[0] = wind_zone_mask_grad.colors[0].lerp(color_target_left, 0.05)
	wind_zone_mask_grad.colors[2] = wind_zone_mask_grad.colors[2].lerp(color_target_right, 0.013)
	wind_zone_mask_grad.colors[1] = wind_zone_mask_grad.colors[0].lerp(wind_zone_mask_grad.colors[2], 0.07)
	#print(color_target_left)


func _on_timer_timeout():
	queue_next_gust()
	start()


func queue_next_gust():
	print("Next Gust")
	gust_step_index += 1
	if gust_step_index >= gust_curves.size():
		gust_step_index = 0
	print("Gust set to index: ", gust_step_index)
	gust_curve = gust_curves[gust_step_index]
