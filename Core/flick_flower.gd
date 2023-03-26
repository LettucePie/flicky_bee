extends Node3D

@onready var anim = $AnimationTree
@onready var head = $Head
@onready var flower_top = $Head/Flower_Top
@onready var skeleton = $Flower_Stem/Flower_Arm/Skeleton3D
var head_boneid : int


# Called when the node enters the scene tree for the first time.
func _ready():
	head_boneid = skeleton.find_bone("Head")
	$Flower_Stem/AnimationPlayer.speed_scale = 3


func _process(delta):
	var head_tran = skeleton.get_bone_global_pose(head_boneid)
	var head_quat = head_tran.basis.get_rotation_quaternion()
	head.set_quaternion(head_quat)
	head.set_position(head_tran.origin)


func _bend_flower(angle, tension_percent):
	print("Bend flower angle :", angle)
	anim.set("parameters/Bend_Blend/blend_amount", tension_percent)
	rotation = Vector3(0, -angle + (PI / 2), 0)
	flower_top.rotation = Vector3(0, angle, 0)


func _flick_flower():
	anim.set("parameters/Bend_Blend/blend_amount", 0.0)
	anim.set("parameters/OneShot/request", 1)
