extends Control

signal end_game()

@export var score_pop_scene : PackedScene

var health_total := 10.0
var health := 10.0 
var hp_bar : TextureProgressBar

var fly_total := 5.0
var fly := 5.0
var fly_bar : TextureProgressBar

var distance : float
var score : int

# Called when the node enters the scene tree for the first time.
func _ready():
	hp_bar = $Health_Meter/HealthBar
	fly_bar = $Flight_Meter/FlyBar
	_update_score(0, 0)
	_setup()


func _setup() -> void:
	self.show()
	$Health_Meter.show()
	$Flight_Meter.show()
	_update_score(0, 0)
	_update_distance(0)
	$PauseButton.show()
	$Pause.hide()


func _update_health_bar(new_health : float, total : float) -> void:
	health_total = total
	health = clamp(new_health, 0.0, health_total)
	if hp_bar != null:
		hp_bar.max_value = health_total
		hp_bar.value = health
		hp_bar.step = 0.05


func _update_fly_bar(new_flight : float, total : float) -> void:
	fly_total = total
	fly = clamp(new_flight, 0.0, fly_total)
	if fly_bar != null:
		fly_bar.max_value = fly_total
		fly_bar.value = fly
		fly_bar.step = 0.05


func _update_score(difference : int, total : int) -> void:
	if difference > 0:
		var new_pop = score_pop_scene.instantiate()
		new_pop.text = "+ " + str(difference)
		add_child(new_pop)
	$Center_Dock/Frame/Box1/Score.text = str(total)
	score = total


func _update_distance(dist : float) -> void:
	distance = dist
	$Center_Dock/Frame/Box2/Distance.text = str(distance) + " m"


func _player_death() -> void:
	$Health_Meter.hide()
	$Flight_Meter.hide()


func _on_play_again_pressed():
	emit_signal("play_again")


func _on_pause_pressed():
	$PauseButton.hide()
	$Pause.show()
	get_tree().paused = true


func _on_continue_pressed():
	$PauseButton.show()
	$Pause.hide()
	get_tree().paused = false


func _on_return_pressed():
	get_tree().paused = false
	emit_signal("end_game")
	self.hide()
