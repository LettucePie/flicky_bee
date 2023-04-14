extends ColorRect

var tag : PriceTag

func _set_tag(t : PriceTag) -> void:
	tag = t
	$Top/Label.text = "Nice!\nYou unlocked " + t.acc_name
	$CenterIcon.texture = t.acc_icon
	$AnimationPlayer.play("Reward")


func _vanish() -> void:
	$AnimationPlayer.play("Vanish")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Vanish":
		self.hide()
