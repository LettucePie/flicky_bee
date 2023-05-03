extends Control


signal play_again()
signal quit_out()

var score_card : Array
var furthest_distance : float
var replaying := false
var start_time : int
var target_time : int
var checked_scores : Array

var suspense := false
@onready var record_score = $Panel/Content/Records/RecordScore/RecordScore
@onready var record_dist = $Panel/Content/Records/RecordDist/RecordDist
var new_score := false
var new_dist := false

## Working off the enum values assigned as "type_id"
## [Combs, Jars, Flowers, Enemies]
var counts = [0, 0, 0, 0]
@onready var labels = [
	$Panel/Content/Combs/Comb_Score,
	$Panel/Content/Jars/Jar_Score,
	$Panel/Content/Flowers/Flower_Score
]
@onready var dings = [
	$CombDing,
	$JarDing,
	$FlowerDing
]
var score_tally := 0


func _set_results(sc, score, furthest, persist) -> void:
	replaying = false
	score_card = sc
	furthest_distance = furthest
	checked_scores.clear()
	for i in counts:
		i = 0
	score_tally = 0
	record_score.text = str(persist.highest_score)
	record_dist.text = str(
		snapped(persist.furthest_distance, 0.1)
	)
	if score >= persist.highest_score:
		new_score = true
	if furthest >= persist.furthest_distance:
		new_dist = true
	$AnimationPlayer.play("Start")
	


func _play_again(extra_arg_0):
	print("Play Again pressed with : ", extra_arg_0)
	if extra_arg_0:
		emit_signal("play_again")
	else:
		emit_signal("quit_out")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Start":
		_stage_setting(1)


func _stage_setting(step : int):
	if step == 1:
		start_time = Time.get_ticks_msec()
		var modifier = 800
		if furthest_distance > 40:
			modifier += 800
		if furthest_distance > 100:
			modifier += 800
		target_time = start_time + modifier
		$Panel/Content/RunDist.show()
		$Panel/Content/Bar.show()
#		$Panel/Content/BestDist.show()
		$Panel/Content/Combs.show()
		$Panel/Content/Jars.show()
		$Panel/Content/Flowers.show()
		$Panel/Content/RunScore.show()
		replaying = true
	if step == 2:
		start_time = Time.get_ticks_msec()
		target_time = start_time + 800
		suspense = true


func _process(delta):
	if replaying:
		var current = Time.get_ticks_msec()
		var percent = inverse_lerp(
			start_time, target_time, current
		)
		if percent > 1.0:
			percent = 1.0
			replaying = false
			_stage_setting(2)
		var timeline = snapped(
				lerp(0.0, furthest_distance, percent),
				0.1
			)
		$Panel/Content/RunDist/RunDist.text = str(timeline)
		$Panel/Content/Bar.value = percent
		if score_card.front() != null:
			while score_card.front()["distance"] <= timeline:
				print(score_card.size())
				var score = score_card.pop_front()
				counts[score["type_id"]] += score["start_value"]
				labels[score["type_id"]].text = str(counts[score["type_id"]])
				score_tally += score["fixed_value"]
				$Panel/Content/RunScore/RunScore.text = str(score_tally)
				dings[score["type_id"]].play()
				checked_scores.append(score)
				if score_card.size() <= 0:
					print("Break TimeLine Loop")
					break
	if suspense:
		var current = Time.get_ticks_msec()
		if inverse_lerp(
			start_time, target_time, current
		) >= 1.0:
			suspense = false
			$RecordDing.playing = (new_score or new_dist)
			$Panel/Content/BestScore.visible = new_score
			$Panel/Content/BestDist.visible = new_dist
			$Panel/Content/Records.show()
			$Panel/Buttons.show()
