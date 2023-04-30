extends Node3D

@onready var anim = $AnimationTree
@onready var head = $Flower_Head
#@onready var flower_top = $Head/Flower_Top
@onready var skeleton = $Flower_Stem/Flower_Arm/Skeleton3D
var flower_top = null
var head_boneid : int


func _assign_flower(flower : String) -> void:
#	print("Assigning Flower: ", flower)
	if head != null:
#		print("Flower Head wasn't null")
		head._set_flower(flower)
		flower_top = head._return_flower()
	else:
#		print("Flower Head was null")
		$Flower_Head._set_flower(flower)


func _ready():
	flower_top = head._return_flower()
	head_boneid = skeleton.find_bone("Head")


func _process(delta):
	var head_tran = skeleton.get_bone_global_pose(head_boneid)
	var head_quat = head_tran.basis.get_rotation_quaternion()
	head.set_quaternion(head_quat)
	head.set_position(head_tran.origin)


func _bend_flower(angle, tension_percent) -> void:
	print("Bend Flowetop: ", flower_top)
	anim.set("parameters/Bend_Blend/blend_amount", tension_percent)
	rotation = Vector3(0, -angle + (PI / 2), 0)
	flower_top.rotation = Vector3(0, angle, 0)


func _flick_flower():
	anim.set("parameters/Bend_Blend/blend_amount", 0.0)
	anim.set("parameters/OneShot/request", 1)


func _return_top_pos_rot() -> Array:
	var result = [Vector3.ZERO, Vector3.ZERO]
	result[0] = head.get_position()
	result[1] = head.get_rotation()
	return result


func _return_trace() -> Node3D:
	return head._return_trace()
