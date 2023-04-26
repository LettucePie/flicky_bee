extends Control

@onready var persist_scene = preload("res://Play/persist.tscn")
@onready var play_scene = preload("res://Play/play_1.tscn")

@onready var music_slide = $Options/VBox/Music/Music_Slide
@onready var sfx_slide = $Options/VBox/SFX/SFX_Slide

var persist_node : Persist
var play_node : Node

var ios_failure := false

func _ready():
	persist_node = persist_scene.instantiate()
	get_window().add_child.call_deferred(persist_node)
	persist_node._load_game()
	_reflect_settings()
	_update_score()
	_hide_submenus()
	if OS.has_feature("ios") \
	or OS.has_feature("web"):
		$Main/ButtonBox/Quit.queue_free()


func _reflect_settings() -> void:
	if persist_node != null:
		music_slide.value = persist_node.music_vol
		sfx_slide.value = persist_node.sfx_vol
		AudioServer.set_bus_volume_db(1, linear_to_db(persist_node.music_vol))
		AudioServer.set_bus_volume_db(2, linear_to_db(persist_node.sfx_vol))


func _update_score() -> void:
	if persist_node != null:
		$Main/ScoreCard/Box/ScoreContainer/Score.text = str(
			persist_node.highest_score
		)
		$Main/ScoreCard/Box/DistContainer/Distance.text = str(
			snapped(persist_node.furthest_distance, 0.1)
		) + " m"


func _update_current_accessories() -> void:
	$Edit._stock_shelves(persist_node)


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
	## or OS.has_feature androidRelease
	if OS.has_feature("ios") and persist_node.ios_plugs != null:
		var plugin = persist_node.ios_plugs
		if plugin.store_info_state == plugin.STATE.EMPTY:
			plugin.store_info_complete.connect(_finish_queue)
			plugin._request_store_info()
			_spawn_queue()
		elif plugin.store_info_state == plugin.STATE.COMPLETE:
			_finish_queue()
	else:
		_update_current_accessories()
		$AnimationPlayer.play("Edit_Open")
		$Edit._set_active_category(0)
		$Edit._set_budget(persist_node.honey_points)


func _spawn_queue() -> void:
	print("Create queue")
	print("Create Fail Timout that runs FinishQueue")


func _finish_queue() -> void:
	print("Kill queue")
	_update_current_accessories()
	$AnimationPlayer.play("Edit_Open")
	$Edit._set_active_category(0)
	$Edit._set_budget(persist_node.honey_points)


func _on_options_pressed():
	print("Options Pressed")
	$AnimationPlayer.play("Options_Open")


func _on_help_pressed():
	print("Help Pressed")
#	$Help.show()
	$AnimationPlayer.play("Help_Open")


func _on_quit_pressed():
	print("Quit Pressed")
	get_tree().quit()


func _on_done_edit_pressed():
	print("Finish Edit Pressed")
	$AnimationPlayer.play("Edit_Close")


func _on_music_slide_value_changed(value):
	music_slide.value = value


func _on_sfx_slide_value_changed(value):
	sfx_slide.value = value


func _on_done_options_pressed(save : bool) -> void:
	print("Finished with Options, Applying changes : ", save)
	if persist_node != null and save:
		persist_node.music_vol = music_slide.value
		persist_node.sfx_vol = sfx_slide.value
		persist_node._save_game()
		_reflect_settings()
	elif !save:
		_reflect_settings()
	$AnimationPlayer.play("Options_Close")


func _on_tutorial_button_pressed():
	print("Tutorial Pressed")
	$Help/Tutorial.show()


func _on_privacy_policy_pressed():
	print("Privacy Policy Pressed")
	var web_string = "https://raw.githubusercontent.com/LettucePie/flicky_bee/main/PRIVACY.md"
	if OS.has_feature("macos"):
		OS.shell_open(web_string)
	else:
		OS.shell_open(web_string.uri_encode())


func _on_website_pressed():
	print("Website Pressed")
	var web_string = "https://lettucepie.itch.io/flicky-bee"
	if OS.has_feature("macos"):
		OS.shell_open(web_string)
	else:
		OS.shell_open(web_string.uri_encode())


func _on_close_help_pressed():
#	$Help.hide()
	$AnimationPlayer.play("Help_Close")

