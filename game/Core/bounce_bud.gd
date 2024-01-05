extends Area3D

var bounced := false


func _ready():
	rotation.y = randf_range(0, PI * 1.9)
	bounced = false


func _on_body_entered(body):
	if body.is_in_group("Player") and bounced == false:
		print("BounceBud Boing Anim")
		bounced = true
		$AnimationPlayer.play("Boing")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Boing":
		bounced = true
		$AnimationPlayer.play("Shrink")
