extends Node2D

var start_point : Vector2
var target_point : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	$Line2D.clear_points()
	$Line2D.add_point(Vector2.ZERO)
	$Line2D.add_point(Vector2.ZERO)


func _assign_start_point(point : Vector2) -> void:
	start_point = point
	self.show()
	$Target.hide()
	$Line2D.show()
	$Line2D.set_point_position(0, point)
	$Line2D.set_point_position(1, point + (Vector2.UP * 20))


func _update_target_point(point : Vector2) -> void:
	target_point = point
	$Target.show()
	$Target.position = point
	var half = start_point.lerp(point, 0.5)
	$Line2D.set_point_position(1, half)


func _cancel() -> void:
	$Target.hide()
	target_point = start_point
	$Line2D.set_point_position(0, start_point)
	$Line2D.set_point_position(1, start_point + (Vector2.UP * 20))


func _release() -> void:
	self.hide()
