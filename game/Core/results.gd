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
var pile_honey := false
var honey_pile_target := 0
@onready var record_score = $Panel/Content/Records/RecordScore/RecordScore
@onready var record_dist = $Panel/Content/Records/RecordDist/RecordDist
var new_score := false
var new_dist := false

## Working off the enum values assigned as "type_id"
## [Combs, Jars, Flowers, Enemies]
var counts : Array
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
	suspense = false
	score_card = sc
	furthest_distance = furthest
	checked_scores.clear()
	counts.clear()
	counts = [0, 0, 0, 0]
	for l in labels:
		l.text = "0"
	score_tally = 0
	$Panel/Content/RunScore/RunScore.text = str(score_tally)
	honey_pile_target = persist.honey_points
	record_score.text = str(persist.highest_score)
	record_dist.text = str(
		snapped(persist.furthest_distance, 0.1)
	)
	new_score = false
	new_dist = false
	if score >= persist.highest_score:
		new_score = true
	if furthest >= persist.furthest_distance:
		new_dist = true
	$AnimationPlayer.play("Start")
	


func _play_again(extra_arg_0):
	get_tree().paused = false
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


func _process(_delta):
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
		if score_card.size() > 0:
			while score_card.front()["distance"] <= timeline:
				var score = score_card.pop_front()
				counts[score["type_id"]] += 1
				labels[score["type_id"]].text = str(counts[score["type_id"]])
				score_tally += score["fixed_value"]
				$Panel/Content/RunScore/RunScore.text = str(score_tally)
				dings[score["type_id"]].play()
				checked_scores.append(score)
				if score_card.size() <= 0:
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
			pile_honey = true
			start_time = current
			target_time = current + 600
			$Panel/Content/HoneyPoints.show()
			$Panel/Content/HoneyPoints/HP.text = "0"
	if pile_honey:
		var current = Time.get_ticks_msec()
#		print("Piling Honey | target_time ",  target_time, " current_time ", current)
		var time_percent = inverse_lerp(start_time, target_time, current)
		$Panel/Content/HoneyPoints/HP.text = str(
			roundi(lerp(0, honey_pile_target, time_percent))
		)
		if time_percent >= 1.0:
			pile_honey = false
			$Panel/Content/HoneyPoints/HP.text = str(honey_pile_target)
