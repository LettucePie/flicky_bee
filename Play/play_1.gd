extends Node

@export var player_scene : PackedScene
@export var life_time := 10.0
@export var flight_reserve := 5.0
@export var rest_time := 2.0
@export var flight_bound := 90.0
@export var comb_value : int = 1
@export var jar_value : int = 2
@export var flower_value : int = 2

enum Collect {Comb, Jar, Flower}
@onready var collect_values = [comb_value, jar_value, flower_value]
@onready var collect_names = ["Comb", "Jar", "Flower"]

var persist : Persist
var menu = null
##
## Player Status
##
var player = null
var camera_target := Vector3.ZERO
var traveling := false
var score_card := []
var platform_score := 0
var comb_count := 0
var jar_count := 0
var flower_count := 0
var current_platform : Area3D
var current_flower : Node3D
var furthest_distance := 0.0
var pause_score := 0
var pause_distance := 0.0
var game_started := false
var time := 10.0
var flight := 5.0
##
## HUD
##
var max_dimension := Vector2.ZERO
var left_2d_bound := Vector2.ZERO
var right_2d_bound := Vector2.ZERO
##
## Input Handling
##
var touching = false
var touch_start := Vector2.ZERO
var player_pos_2d := Vector2.ZERO
var flick_trajectory := Vector2.ZERO
var flick_target := Vector3.ZERO
var flick_valid := false
var flying := false
##
##
##
var grass_patches : Array


# Called when the node enters the scene tree for the first time.
func _ready():
	if get_window().get_child_count() <= 1:
		_setup(null, null)


func _setup(menu_node : Control, persist_node : Persist):
	print("Setup")
	menu = menu_node
	persist = persist_node
	$Generator._clear_platforms()
	$Generator._generate(20, 0.0, persist.flower)
	camera_target = Vector3.ZERO
	_spawn_player()
	_establish_bounds()
#	$Light.shadow_enabled = persist_node.shadows
	time = life_time
	flight = flight_reserve
#	$Life_Timer.stop()
#	$Rest_Timer.stop()
	platform_score = 0
	score_card.clear()
	jar_count = 0
	comb_count = 0
	flower_count = 0
	furthest_distance = 0
	pause_score = 0
	pause_distance = 0.0
	touching = false
	flying = false
	flick_valid = false
	game_started = false
	traveling = false
#	$Arc_Visual.hide()
#	$Knob_Visual.hide()
#	$HUD._update_health_bar(time, life_time)
#	$HUD._update_fly_bar(flight, flight_reserve)
#	$HUD._setup()
#	$Results.hide()
	grass_patches = [$Grass_Patch1, $Grass_Patch2, $Grass_Patch3]
	var grass_point = 60
	for g in grass_patches:
		g.set_position(Vector3(0, -5, grass_point))
		grass_point -= 60


func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT \
	or what == NOTIFICATION_APPLICATION_PAUSED:
		print("Device Leaving Focus at ", Time.get_unix_time_from_system())
		if persist != null:
			_register_progress()
#		$HUD._on_pause_pressed()


func _spawn_player() -> void:
	print("Spawn Player")
	if player != null:
		player._die()
	player = player_scene.instantiate()
#	player.connect("finished_travel", Callable(self, "_on_player_finished_travel"))
#	player.connect("flick_depleted", Callable(self, "_on_player_flick_depleted"))
	player.finished_travel.connect(_on_player_finished_travel)
	player.flick_depleted.connect(_on_player_flick_depleted)
	player.collected.connect(_on_player_collect)
	player.zoom.connect(_on_player_zoom)
	player.hit.connect(_on_player_hit)
	current_platform = $Generator.starting_platform
	current_flower = current_platform._return_flower()
	player.set_position(current_platform.get_position())
	add_child(player)
	player._assign_accessories(persist.hat, persist.trail)
	_update_camera_target(6.0)


func _update_camera_target(offset : float) -> void:
	print("Camera Target")
	var camera_offset = player.get_position()
	camera_offset.x = 0.0
	camera_offset.y = 13.0
	camera_offset.z -= offset
	camera_target = camera_offset
	if grass_patches.size() > 0:
		_move_grass_patches()


func _move_grass_patches() -> void:
	print("Move Grass")
	var mid_z = grass_patches[1].get_position().z
#	var back_z = grass_patches.back().get_position().z
	if camera_target.z < mid_z:
		var new_back = grass_patches.pop_front()
		var pos = new_back.get_position()
		pos.z -= 120
		new_back.set_position(pos)
		grass_patches.push_back(new_back)


func _process(delta):
#	print("Process")
	$Camera3D.set_position(
		lerp(
			$Camera3D.get_position(), camera_target, delta * 2
			)
		)
	if game_started:
		print("Game Started")
		pass
#		if $Life_Timer.is_stopped():
#			pass
#		else:
#			time = $Life_Timer.time_left
#		$HUD._update_health_bar(time, life_time)
#		$HUD._update_fly_bar(flight, flight_reserve)
	if Input.is_action_pressed("ui_up"):
		$Camera3D.translate(Vector3(0, 0.5, 0))
	if Input.is_action_pressed("ui_down"):
		$Camera3D.translate(Vector3(0, -0.5, 0))
	if player != null:
		if abs(player.get_position().z) > furthest_distance:
			furthest_distance = abs(player.get_position().z)
#			$HUD._update_distance(snapped(furthest_distance, 0.1))


func _input(event):
	if event is InputEventMouseButton and time > 0.0:
		_process_click(event)
	if event is InputEventMouseMotion and time > 0.0:
		if touching:
			_process_drag(event)

###
### The Logic for establishing whether the player is flicking or flying
func _process_click(event : InputEventMouseButton) -> void:
	print("Process Click")
	if !touching and event.pressed:
		touching = true
		touch_start = event.position
		if !traveling:
			player_pos_2d = $Camera3D.unproject_position(player.get_position())
#			$Arc_Visual._assign_start_point(player_pos_2d)
		else:
			pass
#			$Knob_Visual._assign_start_point(touch_start)
	elif !event.pressed:
		touching = false
		touch_start = Vector2.ZERO
		if flick_valid:
			_flick_player()
#			$Arc_Visual._release()
		else:
			print("Flick Invalid")
#			$Arc_Visual._cancel()
		if traveling:
			if player != null:
				player._release_flight()
				flying = false
#			$Knob_Visual._release()

###
### The Logic for controlling which direction the player is flicked,
### and the direction they fly
func _process_drag(event : InputEventMouseMotion) -> void:
	print("Process Drag")
	var direction = touch_start.direction_to(event.position)
	var tension = clamp(
		touch_start.distance_to(event.position),
		0,
		max_dimension.y * 0.4
		)
	print("Process Drag: Traveling ", traveling)
	if !traveling:
		direction *= -1.0
		print("Process Drag: Tension ", tension, " max_dimension.y ", max_dimension.y * 0.1, " player ", player)
		if tension > max_dimension.y * 0.1 and player != null:
			flick_valid = true
			var offset = direction * tension
			flick_trajectory = (player_pos_2d + offset).clamp(
				left_2d_bound, right_2d_bound
			)
			if flick_trajectory.y > player_pos_2d.y:
				flick_trajectory.y = player_pos_2d.y
			flick_target = $Camera3D.project_position(
				flick_trajectory, 12.5
			)
			if flick_target.z > player.get_position().z:
				flick_target.z = player.get_position().z
#			$Arc_Visual._update_target_point(flick_trajectory)
			if current_flower != null:
				var angle = touch_start.angle_to_point(event.position)
				var percent = tension / (max_dimension.y * 0.4)
				current_flower._bend_flower(angle, percent)
		else:
			flick_valid = false
#			$Arc_Visual._cancel()
			if current_flower != null:
				current_flower._bend_flower(0, 0.0)
	else:
		var dir_3d = Vector3(direction.x, 0.0, direction.y)
		tension = clamp(
			touch_start.distance_to(event.position),
			0,
			max_dimension.y * 0.2
			)
		if player != null:
			player._fly_to(dir_3d, flight, tension)
			flying = true
#		$Knob_Visual._update_target_point(event.position)


func _physics_process(delta):
	if flying and touching and !player.bursting:
		flight = clamp(
			flight - (delta * 2),
			0.0,
			flight_reserve
		)


func _flick_player() -> void:
	print("Flick Player")
	if player != null and !traveling:
		traveling = true
		current_flower._flick_flower()
		player._flick_to(flick_target)
		if !game_started:
			game_started = true
#		$Life_Timer.start(time)
#		$Rest_Timer.stop()


func _on_hud_resized():
	print("Window_Resized")
	_establish_bounds()


func _establish_bounds() -> void:
	print("Establish Bounds")
#	var max = get_window().size
#	var max = DisplayServer.window_get_size()
#	max_dimension = $HUD/Max.get_position()
	max_dimension = get_window().size
	var center = max_dimension * 0.5
	left_2d_bound = Vector2(
		clamp(center.x - 540, 0, max_dimension.x), 
			0
		)
	right_2d_bound = Vector2(
		clamp(max_dimension.x - left_2d_bound.x, 0, max_dimension.x), 
			max_dimension.y
		)
	var ratio = max_dimension.x / max_dimension.y
	var fov_percent = clamp(
		inverse_lerp(0.55, 0.45, ratio),
		0.0,
		1.0
	)
	var fov_offset = lerp(0.0, 10.0, fov_percent)
	$Camera3D.fov = 75 + fov_offset


func _on_player_finished_travel(platform):
	print("Finished Travel")
	if $Generator.platforms.find(platform) >= 5:
		for i in 4:
			$Generator.platforms.pop_front().queue_free()
		var last_platform = $Generator.platforms.back()
		$Generator._clear_gaps(player.position.z + 8.0)
#		$Generator._clear_gaps(last_platform.get_position().z)
		if persist != null:
			$Generator._generate(4, last_platform.get_position().z, persist.flower)
		else:
			$Generator._generate(4, last_platform.get_position().z, "default")
	current_platform = platform
	current_flower = current_platform._return_flower()
	traveling = false
	touching = false
	flick_valid = false
	flying = false
#	$Arc_Visual.hide()
#	$Knob_Visual.hide()
	_update_camera_target(6.0)
#	$Life_Timer.stop()
#	$Rest_Timer.start(rest_time)
	time = clamp(time + 1.0, 0.0, life_time)
	flight = clamp(flight + 2.0, 0.0, flight_reserve)
	flower_count += 1
	if persist != null:
		platform_score += _register_point(Collect.Flower)
#	$HUD._update_score(2, platform_score)


func _on_player_flick_depleted() -> void:
	flying = true


func _on_player_collect(obj) -> void:
	print("Player Collect")
	var difference = 0
	if obj == "Honey":
		time = clamp(time + 0.5, 0.0, life_time)
#		$Life_Timer.start(time)
		comb_count += 1
		if persist != null:
			difference = _register_point(Collect.Comb)
	if obj == "Jar":
		time = clamp(time + 2.5, 0.0, life_time)
#		$Life_Timer.start(time)
		jar_count += 1
		if persist != null:
			difference = _register_point(Collect.Jar)
	if obj == "Wing":
		flight = clamp(flight + 2.0, 0.0, flight_reserve)
	platform_score += difference
#	$HUD._update_score(difference, platform_score)


func _on_player_zoom():
	_update_camera_target(3.0)


func _on_player_hit():
	time = clamp(time - 2.5, 0.0, life_time)
#	$Life_Timer.start(time)


func _on_life_timer_timeout():
#	$Life_Timer.stop()
#	$Rest_Timer.stop()
	if persist != null:
		_register_progress()
	score_card.sort_custom(_sort_card)
#	$Results._set_results(
#		score_card,
#		platform_score,
#		furthest_distance,
#		persist
#	)
	get_tree().paused = true


func _sort_card(a, b):
	if a["distance"] < b["distance"]:
		return true
	return false


func _on_rest_timer_timeout():
	pass
#	$Rest_Timer.stop()
#	$Life_Timer.start(time)


func _on_bottom_detect_area_entered(area):
	pass


func _on_top_detect_area_entered(area):
	if area.is_in_group("Player"):
		_update_camera_target(4.0)


func _on_results_play_again():
	_setup(menu, persist)


func _register_progress() -> void:
	persist._register_scores(platform_score, furthest_distance)
	if pause_score > 0:
		persist._add_scores(
			platform_score - pause_score,
			furthest_distance - pause_distance
		)
	else:
		persist._add_scores(
			platform_score,
			furthest_distance
		)
	pause_score = platform_score
	pause_distance = furthest_distance


func _register_point(collect : Collect) -> int:
	var multiplier = clamp(
		floor(furthest_distance / 1000),
		1,
		5
	)
	persist._add_points(multiplier * collect_values[collect])
	score_card.append(
		{
			"type" : collect_names[collect],
			"type_id" : collect,
			"start_value" : collect_values[collect],
			"distance" : snapped(abs(player.get_position().z), 0.1),
			"multiplier" : multiplier,
			"fixed_value" : multiplier * collect_values[collect]
		}
	)
	return multiplier * collect_values[collect]


func _on_results_quit_out():
	if menu != null:
		get_window().add_child(menu)
		get_tree().set_current_scene(menu)
		self.queue_free()
