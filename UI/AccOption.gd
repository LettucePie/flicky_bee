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
	$Price.text = ""
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
	if !owned:
		$Icon/Status.texture = lock_overlay
		$Price.text = price_string
	elif equipped:
		$Icon/Status.texture = equipped_overlay


func _on_gui_input(event):
	if event is InputEventMouseButton:
		emit_signal("tag_selected", tag)


func _change_status(owned : bool, equipped : bool) -> void:
	print(tag.acc_name, " Button Updated")
	if owned:
		if equipped:
			$Icon/Status.texture = equipped_overlay
		else:
			$Price.text = ""
			$Icon/Status.texture = null
	else:
		$Icon/Status.texture = lock_overlay
