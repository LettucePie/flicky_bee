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
	_hide_submenus()
	_update_score()


func _update_score() -> void:
	if persist_node != null:
		$Main/ScoreCard/Box/ScoreContainer/Score.text = str(persist_node.highest_score)
		$Main/ScoreCard/Box/DistContainer/Distance.text = str(persist_node.furthest_distance)


func _hide_submenus() -> void:
	$Edit.hide()
	$Options.hide()
	$Help.hide()
	$DarkFade.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_play_pressed():
	play_node = play_scene.instantiate()
	get_window().add_child(play_node)
	play_node._setup(self, persist_node)
	get_tree().set_current_scene(play_node)
	get_window().remove_child(self)


func _on_edit_pressed():
	print("Edit Pressed")
	$AnimationPlayer.play("Edit_Open")


func _on_options_pressed():
	print("Options Pressed")
	$AnimationPlayer.play("Options_Open")


func _on_help_pressed():
	print("Help Pressed")
	$Help.show()


func _on_quit_pressed():
	print("Quit Pressed")
	get_tree().quit()


func _on_done_edit_pressed():
	print("Finish Edit Pressed")
	$AnimationPlayer.play("Edit_Close")


func _on_done_options_pressed(save : bool) -> void:
	print("Finished with Options, Applying changes : ", save)
	$AnimationPlayer.play("Options_Close")
