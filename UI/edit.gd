extends Panel

@onready var categories = [
	$Vbox/Hats,
	$Vbox/Trails,
	$Vbox/Flowers
]
@export var equip_icon : Texture2D
@export var remove_icon : Texture2D

var current_category := 0
var persist_node : Persist
var honey_points := 0
var current_tag : PriceTag


func _stock_shelves(persist : Persist) -> void:
	persist_node = persist
	_set_current_accessories(persist.hat, persist.trail, persist.flower)
	_set_budget(persist.honey_points)
	for c in categories:
		c._stock_gallery(persist, self)


func _set_budget(points : int) -> void:
	honey_points = points
	$Header/Vbox/Hbox/HoneyPoints.text = str(honey_points)


func _set_current_accessories(
	hat : String, 
	trail : String, 
	flower : String
	) -> void:
	print("Setting Equipped items, ", hat, " ", trail, " ", flower)
	$Vbox/Hats._set_current(hat)
	$Vbox/Trails._set_current(trail)
	$Vbox/Flowers._set_current(flower)


func _set_active_category(index : int) -> void:
	if categories.size() > 0:
		for c in categories:
			c.visible = false
		categories[index].visible = true
		current_category = index
		current_tag = null
		$Selected.text = ""
		categories[index]._set_all_nonselected()
		var buttons = $Vbox/Category.get_children()
		buttons[index].grab_focus()
	_update_actions(false, false, false, "")
	$Reward.hide()


func _tag_selected(t : PriceTag) -> void:
	if current_tag != t and current_tag != null:
		categories[current_category]._get_item(current_tag)._set_selected(false)
	current_tag = t
	categories[current_category]._get_item(t)._set_selected(true)
	$Selected.text = t.acc_name
	var equip = (persist_node.accessories.has(t.acc_name))
	var redeem = false
	var buy = false
	var message = ""
	if !equip:
		redeem = t.purchase_honey
		if t.honey_amount > honey_points:
			redeem = false
			message = "Not Enough Honey Points"
		buy = t.purchase_usd
	$ActionContainer/Equip.icon = equip_icon
	$ActionContainer/Equip.text = "Equip"
	$ActionContainer/Equip/ButtonSound._set_sound(4)
	$ActionContainer/Buy_Points.text = str(t.honey_amount) + " HP"
	$ActionContainer/Buy_USD.text = str(t.usd_amount)
	if t.acc_name == persist_node.hat \
	or t.acc_name == persist_node.trail \
	or t.acc_name == persist_node.flower:
		$ActionContainer/Equip.icon = remove_icon
		$ActionContainer/Equip.text = "Remove"
		$ActionContainer/Equip/ButtonSound._set_sound(5)
	_update_actions(equip, redeem, buy, message)


func _update_actions(equip : bool, redeem : bool, buy : bool, message : String) -> void:
	$ActionContainer/Message.hide()
	$ActionContainer/Equip.visible = equip
	$ActionContainer/Buy_Points.visible = redeem
	$ActionContainer/Buy_USD.visible = buy
	if message != "":
		$ActionContainer/Message.show()
		$ActionContainer/Message.text = message


func _on_equip_pressed():
	var new_equip = current_tag.acc_name
	if new_equip == persist_node.hat \
	or new_equip == persist_node.trail \
	or new_equip == persist_node.flower:
		new_equip = "default"
	if current_tag.acc_type == current_tag.ACC_TYPE.HAT:
		persist_node.hat = new_equip
	if current_tag.acc_type == current_tag.ACC_TYPE.TRAIL:
		persist_node.trail = new_equip
	if current_tag.acc_type == current_tag.ACC_TYPE.FLOWER:
		persist_node.flower = new_equip
	persist_node._save_game()
	_set_current_accessories(
		persist_node.hat,
		persist_node.trail,
		persist_node.flower
	)
	categories[current_category]._update_stock_status(persist_node)
	_tag_selected(current_tag)


func _on_buy_points_pressed():
	if !persist_node.accessories.has(current_tag.acc_name):
		persist_node._spend_points(current_tag.honey_amount)
		persist_node._add_accessory(current_tag.acc_name)
		_set_current_accessories(
			persist_node.hat,
			persist_node.trail,
			persist_node.flower
		)
		categories[current_category]._update_stock_status(persist_node)
		_set_budget(persist_node.honey_points)
	else:
		_stock_shelves(persist_node)
	_tag_selected(current_tag)
	$Reward._set_tag(current_tag)


func _on_buy_usd_pressed():
	print("Panic")
	if persist_node != null:
		if OS.has_feature("ios") and persist_node.ios_plugs != null:
			$PurchaseQueue._queue()
			if !persist_node.ios_plugs.purchase_complete.is_connected(_purchase_result):
				persist_node.ios_plugs.purchase_complete.connect(_purchase_result)
			persist_node.ios_plugs._request_purchase(current_tag.prod_id)
		if OS.has_feature("playstore") and persist_node.play_plugs != null:
			$PurchaseQueue._queue()
			if !persist_node.play_plugs.purchase_complete.is_connected(_purchase_result):
				persist_node.play_plugs.purchase_complete.connect(_purchase_result)
			if !persist_node.play_plugs.turtle_speed_purchase.is_connected(_purchase_turtle_speed):
				persist_node.play_plugs.turtle_speed_purchase.connect(_purchase_turtle_speed)
			if persist_node.play_plugs.connected:
				persist_node.play_plugs._request_purchase(current_tag.prod_id)
			else :
				if persist_node.play_plugs._connection_state() != 3:
					if !persist_node.play_plugs.sku_catalog_report.is_connected(_reconnect_playstore):
						persist_node.play_plugs.sku_catalog_report.connect(_reconnect_playstore)
						persist_node.play_plugs._establish_connection()
				else:
					$PurchaseQueue._stop()
					$PurchaseFailure.show()
					$PurchaseFailure/Panel/Label.text = "Connection to Playstore is Closed."


func _reconnect_playstore() -> void:
	if persist_node.play_plugs.connected:
		print("Playstore Reconnected and ready to start purchase request")
		persist_node.play_plugs._request_purchase(current_tag.prod_id)


func _purchase_queue_timeout() -> void:
	print("Purchase Queue Timed Out, sending Error")
	_purchase_result(false)


func _purchase_turtle_speed() -> void:
	print("Purchase is moving at turtle speed...")
	$PurchaseQueue._extend(65)


func _purchase_result(result) -> void:
	print("Attempt to purchase was a totally epic ", result)
	$PurchaseQueue._stop()
	if result:
		persist_node._add_accessory(current_tag.acc_name)
		_set_current_accessories(
			persist_node.hat,
			persist_node.trail,
			persist_node.flower
		)
		categories[current_category]._update_stock_status(persist_node)
		_tag_selected(current_tag)
		$Reward._set_tag(current_tag)
	else:
		$PurchaseFailure.show()


### This is for the Restored Purchases
func _update_all_stock_status():
	if persist_node != null:
		for c in categories:
			c._update_stock_status(persist_node)


func _on_error_ok_pressed():
	$PurchaseFailure.hide()


func _on_visibility_changed():
	if visible:
		$PurchaseQueue.hide()
		$PurchaseFailure.hide()
		$Reward.hide()
