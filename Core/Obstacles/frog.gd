extends Node3D

@export var lunge_interval = 2.5
@onready var anim = $Frog/AnimationPlayer
@onready var curve = $Tongue/Path3D.curve

var player_present := false
var player_body : CharacterBody3D
var tongue_length := 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	player_body = null
	$Lunge.start(lunge_interval)
	anim.play("Idle")


func _physics_process(delta):
	if tongue_length > 0.0:
		pass


func _on_lunge_timeout() -> void:
	$Lunge.stop()
	anim.play("Lunge")
	if player_body != null:
		var self_z = self.get_position().z
		var player_z = player_body.get_position().z
		tongue_length = -6.2
		curve.set_point_position(1, Vector3(tongue_length, 0, 0))
		if abs(self_z - player_z) < 3.0:
			print("Player Hit by Frog")


func _on_area_3d_body_entered(body) -> void:
	if body.is_in_group("Player"):
		player_present = true
		player_body = body


func _on_area_3d_body_exited(body) -> void:
	if body.is_in_group("Player"):
		player_present = false
		player_body = null
