extends Control

@export var skip_store := false
@export var audio_bus : AudioBusLayout

@onready var persist_scene = preload("res://Play/persist.tscn")
@onready var play_scene = preload("res://Play/play_1.tscn")

@onready var shadow_toggle = $Options/VBox/ShadowToggle
@onready var clutter_toggle = $Options/VBox/ClutterToggle
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
	$MenuMusic.play()
	if OS.has_feature("ios") \
	or OS.has_feature("web"):
		$Main/ButtonBox/Quit.queue_free()
	if !OS.is_debug_build():
		$ClearData.queue_free()
	if OS.has_feature("ios") and persist_node.ios_plugs != null:
		print("Keep IOS Restore Purchases Button")
	elif OS.has_feature("playstore") and persist_node.play_plugs != null:
		print("Keep PlayStore Restore Purchases Button")
	else:
		print("Remove Restore Purchases Button.")
		$Help/VBoxContainer/RestorePurchases.queue_free()


func _reflect_settings() -> void:
	if persist_node != null:
		shadow_toggle.button_pressed = persist_node.shadows
		clutter_toggle.button_pressed = persist_node.clutter
		music_slide.value = persist_node.music_vol
		sfx_slide.value = persist_node.sfx_vol
		AudioServer.set_bus_volume_db(1, linear_to_db(persist_node.music_vol))
		AudioServer.set_bus_volume_db(2, linear_to_db(persist_node.sfx_vol))
		$Help/VBoxContainer/Version.text = "Version " + str(persist_node.game_ver)


func _update_score() -> void:
	if persist_node != null:
		$Main/ScoreCard/Box/ScoreContainer/Score.text = str(
			persist_node.highest_score
		)
		$Main/ScoreCard/Box/DistContainer/Distance.text = str(
			snapped(persist_node.furthest_distance, 0.1)
		) + " m"


func _update_current_accessories() -> void:
	print($Edit)
	$Edit._stock_shelves(persist_node)


func _hide_submenus() -> void:
	$Edit.hide()
	$Options.hide()
	$Help.hide()
	$DarkFade.hide()


func _on_play_pressed():
	print("Play Pressed")
#	self.hide()
	play_node = play_scene.instantiate()
	play_node.fully_initiated.connect(_play_scene_ready)
	get_window().add_child(play_node)
#	play_node._setup(self, persist_node)
#	play_node.call_deferred("_setup", self, persist_node)


func _play_scene_ready() -> void:
	print("Play Scene is ready")
	if play_node != null:
		print("Sending self: ", self, " and persist: ", persist_node, " To playscene _setup")
		play_node._setup(self, persist_node)
		get_tree().set_current_scene(play_node)
		get_window().remove_child(self)


func _on_edit_pressed():
	print("Edit Pressed")
	var queue = false
	if (OS.has_feature("ios") and persist_node.ios_plugs != null) \
	or (OS.has_feature("playstore") and persist_node.play_plugs != null):
		queue = true
	if queue and OS.has_feature("ios"):
		var plugin = persist_node.ios_plugs
		if plugin.store_info_state == plugin.STATE.EMPTY:
			plugin.store_info_complete.connect(_finish_queue)
			print("***ios*** Edit Button Requesting store info.")
			plugin._request_store_info()
			_spawn_queue()
		elif plugin.store_info_state == plugin.STATE.COMPLETE:
			print("***ios*** Edit Button loading in previously requested Store Info")
			_finish_queue()
	elif queue and OS.has_feature("playstore"):
		var plugin = persist_node.play_plugs
		if !plugin.sku_cataloged and !plugin.requesting_sku_catalog:
			plugin.sku_catalog_report.connect(_finish_queue)
			plugin._request_SKUs()
			_spawn_queue()
		elif plugin.sku_cataloged:
			_finish_queue()
	else:
		_finish_queue()


func _spawn_queue() -> void:
	print("Spawning QUEUE")
	$PurchaseQueue._queue()


func _finish_queue() -> void:
	print("Finishing QUEUE")
	$PurchaseQueue._stop()
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


func _on_shadow_toggled(button_pressed):
	print("Shadows Toggled : ", button_pressed)


func _on_clutter_toggle_toggled(button_pressed):
	print("Clutter Toggled : ", button_pressed)


func _on_music_slide_value_changed(value):
	music_slide.value = value


func _on_sfx_slide_value_changed(value):
	sfx_slide.value = value


func _on_done_options_pressed(save : bool) -> void:
	print("Finished with Options, Applying changes : ", save)
	if persist_node != null and save:
		persist_node.shadows = shadow_toggle.button_pressed
		persist_node.clutter = clutter_toggle.button_pressed
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
	OS.shell_open(web_string)


func _on_website_pressed():
	print("Website Pressed")
	var web_string = "https://lettucepie.itch.io/flicky-bee"
	OS.shell_open(web_string)


func _on_restore_purchases_pressed():
	print("Restore Purchases Pressed")
	if OS.has_feature("ios") and persist_node.ios_plugs != null:
		$PurchaseQueue._queue()
		if !persist_node.ios_plugs.update_purchases.is_connected(_purchase_restoration_finished):
			persist_node.ios_plugs.update_purchases.connect(_purchase_restoration_finished)
		persist_node.ios_plugs._request_receipts(true)
	if OS.has_feature("playstore") and persist_node.play_plugs != null:
		$PurchaseQueue._queue()
		if !persist_node.play_plugs.update_purchases.is_connected(_purchase_restoration_finished):
			persist_node.play_plugs.update_purchases.connect(_purchase_restoration_finished)
		if persist_node.play_plugs.connected:
			persist_node.play_plugs._request_receipts()
		else :
			if persist_node.play_plugs._connection_state() != 3:
				if !persist_node.play_plugs.sku_catalog_report.is_connected(_reconnect_playstore):
					persist_node.play_plugs.sku_catalog_report.connect(_reconnect_playstore)
					persist_node.play_plugs._establish_connection()
			else:
				$PurchaseQueue._set_status_message("ERROR", "Connection to PlayStore is Closed.")
				$PurchaseQueue._show_message()


func _reconnect_playstore():
	if persist_node.play_plugs.connected:
		print("PlayStore reconnected, requesting receipts now.")
		persist_node.play_plugs._request_receipts()


func _purchase_restoration_finished(result):
	print("Purchase Restoration Finished with rewsult: ", result)
	if result[0] != "HALT":
		$PurchaseQueue._set_status_message(result[0], result[1])
		$PurchaseQueue._show_message()
	else:
		$PurchaseQueue._extend(30)


func _on_close_help_pressed():
#	$Help.hide()
	$AnimationPlayer.play("Help_Close")


func _on_clear_data_pressed():
	pass
#	persist_node._clear_data()


func _on_purchase_queue_queue_timeout():
	print("Purchase Queue Timed Out")


func _on_tree_entered():
	_update_score()


func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_1:
				_on_edit_pressed()
			elif event.keycode == KEY_2:
				_on_options_pressed()
			elif event.keycode == KEY_3:
				_on_help_pressed()

