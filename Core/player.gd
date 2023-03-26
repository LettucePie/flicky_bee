extends Area3D

class_name Player

signal finished_travel(platform)
signal flick_depleted()
signal collected(obj)

@export var flick_acc_curve : Curve

@export var honey_sound : AudioStreamWAV
@export var jar_sound: AudioStreamWAV
@export var wing_sound : AudioStreamWAV
@export var flower_sound : AudioStreamWAV

@export var anim_lib : AnimationLibrary
@onready var anim = $Turn/Bee/AnimationPlayer

var flick_target : Vector3
var start_point : Vector3
var total_distance : float
var flicked := false
var flown := false
var trace := true
var current_platform = null
var platform_count := 0
##
## Movement
##
var previous_dir : Vector3
var fly_dir := Vector3.FORWARD
var fly_amp := 0.0
var fly_force := 1.0
var initial_acc := 12.0
#var drag := 0.05
var final_acc := 4.0
var speed := 0.0
##
##
##
var magnet_col : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.add_animation_library("Base", anim_lib)
	anim.play("Base/Rest")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if flicked:
		if flown:
			fly_force = lerp(fly_force, fly_amp, delta)
			var force = (initial_acc * delta) * fly_force
			translate(fly_dir * force)
			$Buzz.pitch_scale = 0.9 + fly_force
		else:
			var pos = self.get_position()
			var distance = pos.distance_to(flick_target)
			var percent = distance / total_distance
			speed = lerp(
				initial_acc,
				final_acc,
				flick_acc_curve.sample(percent)
				)
			if pos.distance_to(flick_target) <= 0.95:
				pos = pos.move_toward(flick_target, speed * delta)
			else:
				emit_signal("flick_depleted")
				flown = true
				fly_force = 1.0
				fly_amp = 0.1
				if anim.current_animation != "Base/Fly":
					anim.play("Base/Fly")
				if !$Buzz.playing:
					$Buzz.playing = true
			self.set_position(pos)
	if magnet_col.size() > 0:
		for m in magnet_col:
			var m_pos = m.get_global_position()
			var dir = m_pos.direction_to(self.get_position())
			m.global_translate(dir * 4 * delta)
	var pos = self.get_position()
	pos.x = clamp(pos.x, -6.25, 6.25)
	self.set_position(pos)


func _die() -> void:
	print("Player Dying")
	self.queue_free()


func _flick_to(target : Vector3) -> void:
	print("Player Flicking to ", target)
	flick_target = target
	start_point = self.get_position()
	flick_target.y = start_point.y
	total_distance = start_point.distance_to(flick_target)
	speed = initial_acc
	flown = false
	previous_dir = fly_dir
	fly_dir = start_point.direction_to(flick_target)
	fly_force = 1.0
	flicked = true
	_point_forward(fly_dir)


func _fly_to(direction : Vector3, amp : float) -> void:
	flown = true
	previous_dir = fly_dir
	fly_dir = direction
	fly_amp = amp
	_point_forward(fly_dir)
	if anim.current_animation != "Base/Fly":
		anim.play("Base/Fly")
	if !$Buzz.playing:
		$Buzz.playing = true


func _release_flight() -> void:
	fly_amp = 0.1


func _point_forward(direction) -> void:
#	var angle = previous_dir.angle_to(direction)
	var angle = Vector3.BACK.signed_angle_to(direction, Vector3.UP)
	$Turn.rotation = Vector3(0, angle, 0)


func _on_area_entered(area):
	if area.is_in_group("Platform_Area"):
		if !flicked:
			if platform_count == 0:
				## Starting Platform
				current_platform = area
		else:
			if area != current_platform:
				_landed(area)
	if area.is_in_group("Collectable"):
		var c_type = area.get_meta("Type")
		if c_type != null:
			if magnet_col.has(area):
				magnet_col.erase(area)
			area.get_parent().queue_free()
			emit_signal("collected", c_type)
			if c_type == "Honey":
				$Pickup.stream = honey_sound
			if c_type == "Jar":
				$Pickup.stream = jar_sound
			if c_type == "Wing":
				$Pickup.stream = wing_sound
			$Pickup.play()


func _landed(area) -> void:
	print("Player Landed on Platform")
	anim.play("Base/Rest")
	$Buzz.stop()
	$Pickup.stream = flower_sound
	$Pickup.play()
	current_platform = area
	platform_count += 1
	speed = 0
	flicked = false
	flown = false
	previous_dir = fly_dir
	fly_dir = Vector3.FORWARD
	var area_pos = area.get_position()
	var pos = self.get_position()
	pos.x = area_pos.x
	pos.z = area_pos.z
	self.set_position(pos)
	emit_signal("finished_travel", area)


func _on_magnet_area_entered(area):
	if area.is_in_group("Collectable"):
		
		if !magnet_col.has(area.get_parent()):
			magnet_col.append(area.get_parent())


func _on_magnet_area_exited(area):
	if area.is_in_group("Collectable"):
		if magnet_col.has(area.get_parent()):
			magnet_col.erase(area.get_parent())
