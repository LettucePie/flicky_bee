extends Node

class_name PlaystorePlugin

@export var debugging := false
var log : String

var playstore : Object
var connected := false


func _plugin_integrated() -> bool:
	if Engine.has_singleton("GodotGooglePlayBilling"):
		playstore = Engine.get_singleton("GodotGooglePlayBilling")
		_log("Integrated with PlayStore Plugin")
		return true
	else:
		_log("NOT Integrated with PlayStore")
		return false


func _establish_connection() -> void:
	if playstore.has_signal("connected"):
		playstore.connected.connect(_connection_established)
#		print("***play*** Connection Verity Signal found and connected")
		_log("Connection Verity Signal Found")
		playstore.startConnection()
	else:
#		print("***play*** Connection Verity Signal not found...")
		_log("Connection Verity Signal NOT Found")


func _connection_established() -> void:
#	print("***play*** Connected to PlayStore")
	_log("Connected to PlayStore")


## Tools

func _log(s) -> void:
	log += "\n" + str(s)
	$Debug.text = log
