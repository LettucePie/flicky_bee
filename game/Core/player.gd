extends CharacterBody3D

class_name Player

signal finished_travel(platform)
signal flick_depleted()
signal collected(obj)
signal zoom()
signal hit()

@export var flick_acc_curve : Curve

@export var honey_sound : AudioStreamWAV
@export var jar_sound: AudioStreamWAV
@export var wing_sound : AudioStreamWAV
@export var flower_sound : AudioStreamWAV
@export var windhook_sound : AudioStreamWAV
@export var bouncebud_sound : AudioStreamWAV
@export var hit_sound : AudioStreamWAV

@export var anim_lib : AnimationLibrary
@onready var anim = $Turn/Bee/AnimationPlayer

@onready var hat = $Turn/Bee/Body/Head/Hat
@onready var trail = $Turn/Trail

var first_parent = null
var bee_object : Node3D
var flick_target : Vector3
var start_point : Vector3
var total_distance : float
var distance_traveled : float = 0.0
var flicked := false
var flown := false
var trace := true
var current_platform = null
var current_flower = null
var platform_count := 0
##
## Movement
##
var previous_dir : Vector3
var previous_pos : Vector3
var fly_dir := Vector3.FORWARD
var fly_force := 1.0
var fly_target_force := 1.0
var initial_acc := 12.0
var fly_acc = 8.0
var final_acc := 2.0
var speed := 0.0
var bursting := false
var burst_duration = 100
var burst_acc = 12.0
var push : Vector3 = Vector3.ZERO
##
##
##
var magnet_col : Array


func _ready():
	$Hurt.hide()
	first_parent = get_parent()
	bee_object = $Turn/Bee
	anim.add_animation_library("Base", anim_lib)
	anim.play("Base/Rest")
	pass # Replace with function body.


func _assign_accessories(hat_name : String, trail_name : String) -> void:
	hat._set_active(hat_name)
	trail._set_active(trail_name)


func _physics_process(delta):
	previous_pos = self.get_position_delta()
	var pos = self.get_position()
	if flicked:
		if bursting:
			## Wind Burst
#			fly_dir = fly_dir.lerp(Vector3.FORWARD, 0.3)
			speed = lerp(speed, burst_acc * 0.66, delta * 0.5)
			burst_duration -= 1
			if burst_duration <= 0:
				bursting = false
				fly_force = 1.0
				fly_target_force = 0.4
		elif flown:
			## Flight Control
			fly_force = lerp(fly_force, fly_target_force, delta * 3)
			speed = fly_acc * fly_force
			$Buzz.pitch_scale = 0.9 + fly_force
		else:
			## Assume Flicking
			pos = self.get_position()
			distance_traveled += previous_pos.length()
			var percent = distance_traveled / total_distance
			speed = lerp(
				initial_acc,
				final_acc,
				flick_acc_curve.sample(percent)
				)
			speed += 2
			## TODO
			## REverse Percent Travel curve to eliminate weird speedup?
			## Test out more wind push settings
			if distance_traveled >= total_distance:
				emit_signal("flick_depleted")
				flown = true
				fly_force = 0.5
				fly_target_force = 0.2
				if anim.current_animation != "Base/Fly":
					anim.play("Base/Fly")
					bee_object.set_rotation(Vector3(0, PI * -0.5, 0))
				if !$Buzz.playing:
					$Buzz.playing = true
			self.set_position(pos)
		velocity = fly_dir * speed
		velocity += push
		velocity.y = 0
		push = lerp(push, Vector3.ZERO, 0.5)
		if move_and_slide():
			if !flown:
				emit_signal("flick_depleted")
				_switch_to_flight()
	if magnet_col.size() > 0:
		for m in magnet_col:
			var m_pos = m.get_global_position()
			var dir = m_pos.direction_to(self.get_position())
			m.global_translate(dir * 5 * delta)
	pos = self.get_position()
	pos.x = clamp(pos.x, -6.25, 6.25)
	self.set_position(pos)


func _switch_to_flight() -> void:
	flown = true
	fly_force = 0.5
	fly_target_force = 0.2
	if anim.current_animation != "Base/Fly":
		anim.play("Base/Fly")
		bee_object.set_rotation(Vector3(0, PI * -0.5, 0))
	if !$Buzz.playing:
		$Buzz.playing = true


func _hit() -> void:
	$Pickup.set_stream(hit_sound)
	$Pickup.play()
	emit_signal("hit")
	$Hurt._blink()


func _die() -> void:
	self.queue_free()


func _flick_to(target : Vector3) -> void:
	bee_object.get_parent().remove_child(bee_object)
	$Turn.add_child(bee_object)
	bee_object.set_rotation(Vector3(0, PI * -0.5, 0))
	if anim.current_animation != "Base/Fly":
		anim.play("Base/Flick")
	flick_target = target
	start_point = self.get_position()
	flick_target.y = start_point.y
	total_distance = start_point.distance_to(flick_target)
	distance_traveled = 0.0
	speed = initial_acc
	flown = false
	bursting = false
	previous_dir = fly_dir
	fly_dir = start_point.direction_to(flick_target)
	fly_force = 1.0
	flicked = true
	_point_forward(fly_dir)
	trail._activate_trail(true)


func _fly_to(direction : Vector3, flight : float, _tension : float) -> void:
	flown = true
	fly_target_force = 0.4
	if flight > 0.0:
		fly_target_force = 1.0
	previous_dir = fly_dir
	if bursting:
		fly_dir = fly_dir.lerp(direction, 0.05)
	else:
		fly_dir = direction
#	$Turn.set_rotation(Vector3.ZERO)
#	self.set_rotation(Vector3.ZERO)
#	$Turn/Bee.set_position(Vector3.ZERO)
	_point_forward(fly_dir)
	if anim.current_animation != "Base/Fly":
		anim.play("Base/Fly")
		bee_object.set_rotation(Vector3(0, PI * -0.5, 0))
	if !$Buzz.playing:
		$Buzz.playing = true


func _release_flight() -> void:
	fly_target_force = 0.2


func _point_forward(direction) -> void:
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
	if area.is_in_group("Windhook"):
		_switch_to_flight()
		anim.play("Base/Spin")
		var hook_dir = Vector3.FORWARD
		#if area.rotation.y != 0:
			#print("Tilted WindHook true... Rotation: ", area.rotation)
		hook_dir = hook_dir.rotated(
			Vector3.UP, area.rotation.y
		)
		_point_forward(hook_dir)
		fly_dir = hook_dir
		burst_duration = 45
		bursting = true
		speed = burst_acc
		emit_signal("collected", "Wing")
		emit_signal("zoom")
		$Pickup.stream = windhook_sound
		$Pickup.play()
	if area.is_in_group("BounceBud"):
		if area.bounced == false:
			_landed(area)
			$BounceTimer.start(0.2)
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
	anim.play("Base/Rest")
	$Buzz.stop()
	trail._activate_trail(false)
	current_platform = area
	if area.is_in_group("Platform_Area"):
		$Pickup.stream = flower_sound
		current_flower = current_platform._return_flower()
		$Turn.remove_child(bee_object)
		if current_flower.has_method("_return_trace"):
			current_flower._return_trace().add_child(bee_object)
		bee_object.set_rotation(Vector3.ZERO)
	elif area.is_in_group("BounceBud"):
		$Pickup.stream = bouncebud_sound
	$Pickup.play()
	platform_count += 1
	speed = 0
	flicked = false
	flown = false
	bursting = false
	previous_dir = fly_dir
	fly_dir = Vector3.FORWARD
	var area_pos = area.get_position()
	area_pos = area.get_parent().to_global(area_pos)
	var pos = self.get_position()
	pos.x = area_pos.x
	pos.z = area_pos.z
	self.set_position(pos)
	emit_signal("finished_travel", area)


func _on_bounce_timer_timeout():
	$BounceTimer.stop()
	_flick_to((previous_dir * fly_acc) + self.position)


func _on_magnet_area_entered(area):
	if area.is_in_group("Collectable"):
		if !magnet_col.has(area.get_parent()):
			magnet_col.append(area.get_parent())


func _on_magnet_area_exited(area):
	if area.is_in_group("Collectable"):
		if magnet_col.has(area.get_parent()):
			magnet_col.erase(area.get_parent())



