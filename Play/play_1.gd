extends Node

@export var player_scene : PackedScene
@export var life_time := 10.0
@export var flight_reserve := 5.0
@export var rest_time := 2.0
@export var flight_bound := 90.0

##
## Player Status
##
var player = null
var camera_target := Vector3.ZERO
var traveling := false
var platform_score := 0
var furthest_distance := 0.0
var game_started := false
var time := 10.0
var flight := 5.0
##
## HUD
##
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
var flight_strength = 0.0
##
##
##
var grass_patches : Array


# Called when the node enters the scene tree for the first time.
func _ready():
	_setup()


func _setup():
	$Generator._clear_platforms()
	$Generator._generate(200, 0.0)
	camera_target = Vector3.ZERO
	_spawn_player()
	_establish_bounds()
	time = life_time
	flight = flight_reserve
	$Life_Timer.stop()
	$Rest_Timer.stop()
	platform_score = 0
	furthest_distance = 0
	touching = false
	flying = false
	flick_valid = false
	game_started = false
	traveling = false
	$Arc_Visual.hide()
	$Knob_Visual.hide()
	$HUD._update_health_bar(time, life_time)
	$HUD._update_fly_bar(flight, flight_reserve)
	$HUD._setup()
	grass_patches = [$Grass_Patch1, $Grass_Patch2, $Grass_Patch3]
	var grass_point = 60
	for g in grass_patches:
		g.set_position(Vector3(0, -5, grass_point))
		grass_point -= 60


func _spawn_player() -> void:
	if player != null:
		player._die()
	player = player_scene.instantiate()
#	player.connect("finished_travel", Callable(self, "_on_player_finished_travel"))
#	player.connect("flick_depleted", Callable(self, "_on_player_flick_depleted"))
	player.finished_travel.connect(_on_player_finished_travel)
	player.flick_depleted.connect(_on_player_flick_depleted)
	player.collected.connect(_on_player_collect)
	player.set_position($Generator.starting_platform.get_position())
	add_child(player)
	_update_camera_target(6.0)


func _update_camera_target(offset : float) -> void:
	var camera_offset = player.get_position()
	camera_offset.x = 0.0
	camera_offset.y = 13.0
	camera_offset.z -= offset
	camera_target = camera_offset
	if grass_patches.size() > 0:
		_move_grass_patches()


func _move_grass_patches() -> void:
	var mid_z = grass_patches[1].get_position().z
#	var back_z = grass_patches.back().get_position().z
	if camera_target.z < mid_z:
		var new_back = grass_patches.pop_front()
		var pos = new_back.get_position()
		pos.z -= 120
		new_back.set_position(pos)
		grass_patches.push_back(new_back)


func _process(delta):
	$Camera3D.set_position(
		lerp(
			$Camera3D.get_position(), camera_target, delta * 2
			)
		)
	if game_started:
		if $Life_Timer.is_stopped():
			pass
		else:
			time = $Life_Timer.time_left
		$HUD._update_health_bar(time, life_time)
		$HUD._update_fly_bar(flight, flight_reserve)
	if Input.is_action_pressed("ui_up"):
		$Camera3D.translate(Vector3(0, 0.5, 0))
	if Input.is_action_pressed("ui_down"):
		$Camera3D.translate(Vector3(0, -0.5, 0))
	if player != null:
		if abs(player.get_position().z) > furthest_distance:
			furthest_distance = abs(player.get_position().z)
			$HUD._update_distance(snapped(furthest_distance, 0.1))


func _input(event):
	if event is InputEventMouseButton and time > 0.0:
		if !touching and event.pressed:
			touching = true
			touch_start = event.position
			if !traveling:
				player_pos_2d = $Camera3D.unproject_position(player.get_position())
				$Arc_Visual._assign_start_point(player_pos_2d)
			else:
				$Knob_Visual._assign_start_point(touch_start)
		elif !event.pressed:
			touching = false
			touch_start = Vector2.ZERO
			if flick_valid:
				_flick_player()
				$Arc_Visual._release()
			else:
				$Arc_Visual._cancel()
			if traveling:
				if player != null:
					player._release_flight()
					print("Release Flight")
					flying = false
					flight_strength = 0.0
				$Knob_Visual._release()
	if event is InputEventMouseMotion and time > 0.0:
		if touching:
			var direction = touch_start.direction_to(event.position)
			var tension = touch_start.distance_to(event.position)
			if !traveling:
				direction *= -1.0
				tension *= 2.0
				if tension > 150 and player != null:
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
					$Arc_Visual._update_target_point(flick_trajectory)
				else:
					flick_valid = false
					$Arc_Visual._cancel()
			else:
				flight_strength = clamp(
					tension, 0.0, flight_bound
					) / flight_bound
				var dir_3d = Vector3(direction.x, 0.0, direction.y)
				if flight < 1.0:
					flight_strength = clamp(flight, 0.1, 1.0)
				if player != null:
					player._fly_to(dir_3d, flight_strength)
					flying = true
				$Knob_Visual._update_target_point(event.position)


func _physics_process(delta):
	if flying:
		flight = clamp(
			flight - ((flight_strength * 3) * delta),
			0.0,
			flight_reserve
		)


func _flick_player() -> void:
	if player != null and !traveling:
		traveling = true
		player._flick_to(flick_target)
		if !game_started:
			game_started = true
		$Life_Timer.start(time)
		$Rest_Timer.stop()


func _on_hud_resized():
	print("Window_Resized")
	_establish_bounds()


func _establish_bounds() -> void:
#	var max = get_window().size
#	var max = DisplayServer.window_get_size()
	var max = $HUD/Max.get_position()
	var center = max * 0.5
	print("Max ", max, " Center ", center)
	left_2d_bound = Vector2(clamp(center.x - 540, 0, max.x), 0)
	right_2d_bound = Vector2(clamp(max.x - left_2d_bound.x, 0, max.x), max.y)
	print("LeftBound: ", left_2d_bound, " RightBound: ", right_2d_bound)


func _on_player_finished_travel(points):
	print("Player Finished Travel")
	traveling = false
	touching = false
	flick_valid = false
	flying = false
	$Arc_Visual.hide()
	$Knob_Visual.hide()
	_update_camera_target(6.0)
	$Life_Timer.stop()
	$Rest_Timer.start(rest_time)
	time = clamp(time + 1.0, 0.0, life_time)
	flight = clamp(flight + 1.0, 0.0, flight_reserve)
	platform_score += 2
	$HUD._update_score(2, platform_score)


func _on_player_flick_depleted() -> void:
	print("Player Flick ran out of force, switching to Wings")
	flying = true
	flight_strength = 0.1


func _on_player_collect(obj) -> void:
	print("Player Collected ", obj)
	var difference = 1
	if obj == "Honey":
		time = clamp(time + 0.5, 0.0, life_time)
		$Life_Timer.start(time)
	if obj == "Jar":
		difference = 3
		time = clamp(time + 2.5, 0.0, life_time)
		$Life_Timer.start(time)
	if obj == "Wing":
		difference = 3
		flight = clamp(flight + 2.0, 0.0, flight_reserve)
	platform_score += difference
	$HUD._update_score(difference, platform_score)


func _on_life_timer_timeout():
	$Life_Timer.stop()
	print("Player Ran out of Time")
	$HUD._player_death()


func _on_rest_timer_timeout():
	$Rest_Timer.stop()
	$Life_Timer.start(time)


func _on_bottom_detect_area_entered(area):
	pass
#	if area.is_in_group("Player"):
#		_update_camera_target(-4.0)


func _on_top_detect_area_entered(area):
	if area.is_in_group("Player"):
		_update_camera_target(4.0)


func _on_hud_play_again():
	_setup()
