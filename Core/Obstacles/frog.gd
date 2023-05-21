extends Node3D

@export var lunge_interval = 2.5
@onready var anim = $Frog/AnimationPlayer
@onready var idles = ["Idle_1", "Idle_2"]

var player_present := false
var player_body : CharacterBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	player_body = null
	$Lunge.start(lunge_interval)
	anim.play(idles.pick_random())
	$Frog/AnimationPlayer.animation_finished.connect(_on_animation_player_animation_finished)
	if bool(randi() %2):
		self.rotate_y(PI)


func _on_lunge_timeout() -> void:
	anim.play("Lunge")


func _snap_tongue() -> void:
	$Tongue/Tongue/AnimationPlayer.play("Snap")
	$AudioStreamPlayer3D.play()
	if player_body != null:
		var self_z = self.get_position().z
		var player_z = player_body.get_position().z
		if abs(self_z - player_z) < 3.0:
			if player_body.has_method("_hit"):
				player_body._hit()


func _on_animation_player_animation_finished(anim_name):
	$Tongue/Tongue.hide()
	anim.play(idles.pick_random())


func _on_area_3d_body_entered(body) -> void:
	if body.is_in_group("Player"):
		player_present = true
		player_body = body


func _on_area_3d_body_exited(body) -> void:
	if body.is_in_group("Player"):
		player_present = false
		player_body = null


