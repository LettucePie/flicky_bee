extends Control


signal play_again()
signal quit_out()


func _set_results(
	score : int,
	distance : float,
	combs : int,
	jars : int,
	flowers : int,
	persist : Persist
	) -> void:
	$AnimationPlayer.play("Start")
	$Panel/Vbox/Combs/Comb_Score.text = str(combs)
	$Panel/Vbox/Jars/Jar_Score.text = str(jars)
	$Panel/Vbox/Flowers/Flower_Score.text = str(flowers)
	$Panel/Vbox/RunScore/RunScore.text = str(score)
	$Panel/Vbox/RunDist/RunDist.text = str(
		snapped(distance, 0.1)
		) + " m"
	if persist != null:
		$Panel/Vbox/RecordScore/RecordScore.text = str(persist.highest_score)
		$Panel/Vbox/RecordDist/RecordDist.text = str(
			snapped(persist.furthest_distance, 0.1)
		) + " m"


func _play_again(extra_arg_0):
	print("Play Again pressed with : ", extra_arg_0)
	if extra_arg_0:
		emit_signal("play_again")
	else:
		emit_signal("quit_out")
