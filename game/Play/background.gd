extends TextureRect

@export var adjust_amount = 15.0

var start_pos := Vector2.ZERO
var target_pos := Vector2.ZERO
var cloud_start := Vector2.ZERO
var cloud_target := Vector2.ZERO
var switch_up_count := 400


func _ready():
	print(position)
	start_pos = position
	cloud_start = $Clouds.position
	target_pos = start_pos
	cloud_target = cloud_start
	var randx = randf_range(-adjust_amount, adjust_amount)
	target_pos.x = target_pos.x + randx
	cloud_target.x = cloud_target.x + (randx * 1.25)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if switch_up_count > 0:
		position = position.lerp(target_pos, delta / 2)
		$Clouds.position = $Clouds.position.lerp(cloud_target, delta / 2)
		switch_up_count -= 1
	else:
		randomize()
		switch_up_count = randi_range(200, 600)
		target_pos = start_pos
		cloud_target = cloud_start
		var randx = randf_range(-adjust_amount, adjust_amount)
		target_pos.x = target_pos.x + randx
		cloud_target.x = cloud_target.x + (randx * 1.25)
