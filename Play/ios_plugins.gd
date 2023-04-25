extends Node

var in_app_store


func _plugin_integrated() -> bool:
	var integrated = false
	if Engine.has_singleton("InAppStore"):
		in_app_store = Engine.get_singleton("InAppStore")
		integrated = true
	else:
		print("iOS IAP plugin is not available on this platform.")
	return integrated
