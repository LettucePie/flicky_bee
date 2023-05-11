extends Control

@onready var label = $Label

var enemies : Array
var obstacles : Array
var collectables : Array


func _ready():
#	if !OS.has_feature("androiddebug"):
#		self.queue_free()
	get_tree().node_added.connect(_node_added)
	get_tree().node_removed.connect(_node_removed)


func _node_added(node : Node) -> void:
	if node.is_in_group("Enemy") and !enemies.has(node):
		print("Enemy Added: ", node)
		enemies.append(node)
	if node.is_in_group("Collectable") and !collectables.has(node):
		print("Collectable Added: ", node)
		collectables.append(node)
	if node.is_in_group("Obstacle") and !obstacles.has(node):
		print("Obstacle Added: ", node)
		obstacles.append(node)


func _node_removed(node : Node) -> void:
	if node.is_in_group("Enemy") and enemies.has(node):
		print("Enemy Removed: ", node)
		enemies.erase(node)
	if node.is_in_group("Collectable") and collectables.has(node):
		print("Collectable Removed: ", node)
		collectables.erase(node)
	if node.is_in_group("Obstacle") and obstacles.has(node):
		print("Obstacle Removed: ", node)
		obstacles.erase(node)


func _process(delta):
	label.text = "FPS " + str(Performance.get_monitor(Performance.TIME_FPS))
	label.text += "\nENEM_COUNT " + str(enemies.size())
	label.text += "\nOBST_COUNT " + str(obstacles.size())
	label.text += "\nCOLL_COUNT " + str(collectables.size())
