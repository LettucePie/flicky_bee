extends Node3D

@export var flowers : Array[FlowerType] = []
@export var default : NodePath

var flower_top = null
var trace_node = null



# Called when the node enters the scene tree for the first time.
func _ready():
	flower_top = get_node(default)
	_find_trace()


func _return_flower() -> Node3D:
	if flower_top != null:
		return flower_top
	else:
		if flowers.size() > 0:
			flower_top = flowers[0].scene.instantiate()
			self.add_child(flower_top)
			_find_trace()
			return flower_top
		else:
			flower_top = Node3D.new()
			add_child(flower_top)
			return flower_top


func _return_trace() -> Node3D:
	if trace_node != null:
		return trace_node
	else:
		trace_node = Node3D.new()
		if flower_top != null:
			flower_top.add_child(trace_node)
		else:
			add_child(trace_node)
		trace_node.set_position(Vector3(
			0, 
			0.4, 
			0
		))
		trace_node.set_scale(Vector3(
			1.62,
			1.62,
			1.62
		))
		return trace_node


func _find_trace() -> void:
	if flower_top != null:
		for c in flower_top.get_children():
			if c.name == "Trace":
				trace_node = c
	else:
		pass


func _set_flower(flower : String):
	var target = null
	for f in flowers:
		if f.flower_name == flower:
			target = f.scene
	if target != null:
		if is_instance_valid(flower_top):
			flower_top.queue_free()
		flower_top = target.instantiate()
		add_child(flower_top)
		flower_top.rotation.y = PI / 2
		_find_trace()
