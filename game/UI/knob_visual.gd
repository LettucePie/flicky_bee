extends Sprite2D

@export var boundary_size := 90.0
var start_point : Vector2
var target_point : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _assign_start_point(point : Vector2) -> void:
	start_point = point
	self.show()
	self.position = start_point


func _update_target_point(point : Vector2) -> void:
	var distance = clamp(
		start_point.distance_to(point),
		0.0,
		boundary_size
		)
	var direction = start_point.direction_to(point)
	target_point = direction * distance
	$Stick.set_position(target_point)


func _release() -> void:
	self.hide()
