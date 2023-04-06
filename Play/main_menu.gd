extends Control

@onready var persist_scene = preload("res://Play/persist.tscn")
@onready var play_scene = preload("res://Play/play_1.tscn")

var persist_node : Persist
var play_node : Node

func _ready():
	persist_node = persist_scene.instantiate()
	get_window().add_child.call_deferred(persist_node)
	persist_node._load_game()
	if OS.has_feature("ios") \
	or OS.has_feature("web"):
		$ButtonBox/Quit.queue_free()
	$ScoreCard/Box/ScoreContainer/Score.text = str(persist_node.highest_score)
	$ScoreCard/Box/DistContainer/Distance.text = str(persist_node.furthest_distance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_play_pressed():
	play_node = play_scene.instantiate()
	get_window().add_child(play_node)
	play_node._setup(self, persist_node)
	get_window().remove_child(self)
