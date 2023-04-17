extends Panel

@onready var categories = [
	$Vbox/Hats,
	$Vbox/Trails,
	$Vbox/Flowers
]

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
		var buttons = $Vbox/Category.get_children()
		for b in buttons:
			b.disabled = false
		buttons[index].disabled = true
	_update_actions(false, false, false, "")
	$Reward.hide()


func _tag_selected(t : PriceTag) -> void:
	print("EditPanel: Tag Selected: ", t.acc_name)
	current_tag = t
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
	$ActionContainer/Equip.text = "Equip"
	$ActionContainer/Buy_Points.text = str(t.honey_amount) + " HP"
	$ActionContainer/Buy_USD.text = "$" + str(t.usd_amount)
	if t.acc_name == persist_node.hat \
	or t.acc_name == persist_node.trail \
	or t.acc_name == persist_node.flower:
		$ActionContainer/Equip.text = "Remove"
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
