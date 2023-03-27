extends CharacterBody3D

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

var first_parent = null
var bee_object : Node3D
var flick_target : Vector3
var start_point : Vector3
var total_distance : float
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
var fly_dir := Vector3.FORWARD
var fly_force := 1.0
var fly_target_force := 1.0
var initial_acc := 12.0
var fly_acc = 8.0
var final_acc := 2.0
var speed := 0.0
##
##
##
var magnet_col : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	first_parent = get_parent()
	bee_object = $Turn/Bee
	anim.add_animation_library("Base", anim_lib)
	anim.play("Base/Rest")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if flicked:
		if flown:
			fly_force = lerp(fly_force, fly_target_force, delta * 3)
			speed = fly_acc * fly_force
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
			speed += 2
			if pos.distance_to(flick_target) <= 0.05:
				emit_signal("flick_depleted")
				flown = true
				fly_force = 0.5
				fly_target_force = 0.2
				if anim.current_animation != "Base/Fly":
					anim.play("Base/Fly")
				if !$Buzz.playing:
					$Buzz.playing = true
			self.set_position(pos)
		velocity = fly_dir * speed
		velocity.y = 0
		if move_and_slide():
			if !flown:
				emit_signal("flick_depleted")
				flown = true
				fly_force = 0.5
				fly_target_force = 0.2
				if anim.current_animation != "Base/Fly":
					anim.play("Base/Fly")
				if !$Buzz.playing:
					$Buzz.playing = true
#	else:
#		if current_flower != null:
#			var trace = current_flower._return_trace()
#			var trace_global = to_global(trace.get_position())
#			self.set_position(trace_global)
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
	bee_object.get_parent().remove_child(bee_object)
	$Turn.add_child(bee_object)
	bee_object.set_rotation(Vector3(0, PI * -0.5, 0))
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


func _fly_to(direction : Vector3, flight : float) -> void:
	flown = true
	fly_target_force = 0.2
	if flight > 0.0:
		fly_target_force = 1.0
	previous_dir = fly_dir
	fly_dir = direction
#	$Turn.set_rotation(Vector3.ZERO)
#	self.set_rotation(Vector3.ZERO)
#	$Turn/Bee.set_position(Vector3.ZERO)
	_point_forward(fly_dir)
	if anim.current_animation != "Base/Fly":
		anim.play("Base/Fly")
	if !$Buzz.playing:
		$Buzz.playing = true


func _release_flight() -> void:
	fly_target_force = 0.2


func _point_forward(direction) -> void:
#	var angle = previous_dir.angle_to(direction)
	var angle = Vector3.BACK.signed_angle_to(direction, Vector3.UP)
#	var turn_rot = $Turn.get_rotation()
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
	current_flower = current_platform._return_flower()
	$Turn.remove_child(bee_object)
	current_flower._return_trace().add_child(bee_object)
	bee_object.set_rotation(Vector3.ZERO)
#	get_parent().remove_child(self)
#	current_flower._return_trace().add_child(self)
#	self.set_position(Vector3.ZERO)
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

