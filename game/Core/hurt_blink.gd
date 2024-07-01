extends Sprite3D

var blinking := false
var frame_count = 0
var blink_count = 0


func _blink() -> void:
	blinking = true
	frame_count = 0
	blink_count = 3


func _physics_process(_delta):
	if blinking:
		frame_count -= 1
		if frame_count <= 0:
			frame_count = 4
			if self.visible:
				self.visible = false
				if blink_count <= 0:
					blinking = false
			else:
				offset = Vector2(
					randf_range(-120, 120),
					randf_range(-120, 120)
				)
				flip_h = bool(randi() % 2)
				flip_v = bool(randi() % 2)
				pixel_size = randf_range(0.005, 0.01)
				rotate_y(randf_range(PI * 0.1, PI * 2))
				self.visible = true
				blink_count -= 1
