extends Area3D
class_name WindZone

## Singleton
var wind_manager : WindZoneManager = null
var assigned : bool = false

## Components
@onready var wind_area_shape : BoxShape3D = $CollisionShape3D.shape

## Dynamic
var player : Player = null
var influence : Vector3


func _ready():
	call_deferred("shape_wind_area")


func assign_wind_zone_manager(manager : WindZoneManager):
	wind_manager = manager
	assigned = true


func shape_wind_area():
	var north_count = $NorthRay.get_collision_count()
	var south_count = $SouthRay.get_collision_count()
	var closest_distance : float = wind_area_shape.size.z / 2
	var north_target : Vector3 = Vector3.ZERO
	var south_target : Vector3 = Vector3.ZERO
	var gpos : Vector3 = self.global_position
	if north_count > 0:
		for ni in north_count:
			if $NorthRay.get_collider(ni).is_in_group("Checkpoint"):
				var target = $NorthRay.get_collision_point(ni)
				if abs(gpos.z - target.z) < closest_distance:
					closest_distance = abs(gpos.z - target.z)
					north_target = target
	if south_count > 0:
		for si in south_count:
			if $SouthRay.get_collider(si).is_in_group("Checkpoint"):
				var target = $SouthRay.get_collision_point(si)
				if abs(gpos.z - target.z) < closest_distance:
					closest_distance = abs(gpos.z - target.z)
					south_target = target
	wind_area_shape.size.z = closest_distance * 1.9


func _physics_process(delta):
	if player != null and assigned:
		if player.flicked:
			player.push = wind_manager.influence


func _on_body_entered(body):
	if body is Player:
		player = body


func _on_body_exited(body):
	if player != null and body == player:
		player = null

