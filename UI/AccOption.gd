extends Control

signal tag_selected(tag)
signal scrolling(dir)

@export var lock_overlay : Texture2D
@export var equipped_overlay : Texture2D
var tag : PriceTag = null


func _assign_tag(t : PriceTag, owned : bool, equipped : bool):
	tag = t
	$Icon.texture = tag.acc_icon
	$Icon/Status.texture = null
	if !owned:
		$Icon/Status.texture = lock_overlay
	elif equipped:
		$Icon/Status.texture = equipped_overlay
	$Label.text = tag.acc_name
	var price_string = ""
	if tag.purchase_honey:
		price_string = str(tag.honey_amount) + " HP"
	if tag.purchase_usd:
		if price_string != "":
			price_string += "\n"
		price_string += "$" + str(tag.usd_amount)
	if tag.achievable:
		price_string = "Challenge"
	$Price.text = price_string


func _on_gui_input(event):
#	print("Accessory Option Recieved Input Event: ", event)
	if event is InputEventMouseButton:
		emit_signal("tag_selected", tag)
#	if event is InputEventMouseMotion:
#		emit_signal("scrolling", event)


func _change_status(owned : bool, equipped : bool) -> void:
	$Icon/Status.texture = null
	if !owned:
		$Icon/Status.texture = lock_overlay
	elif equipped:
		$Icon/Status.texture = equipped_overlay
