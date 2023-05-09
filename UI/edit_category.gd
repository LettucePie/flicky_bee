extends Control

enum CATEGORY_TYPE {HATS, TRAILS, FLOWERS}

@export var category : CATEGORY_TYPE
@export var inventory : Array[PriceTag] = []
@export var accOption : PackedScene

@onready var current_icon = $Vbox/Current/CurrentIcon
@onready var current_label = $Vbox/Current/CurrentLabel
@onready var gallery_container = $Vbox/ScrollGallery/Gallery

var current_item : String
var gallery_stock : Array
var gallery_held := false

# Called when the node enters the scene tree for the first time.
func _ready():
	var label1 = "Hats"
	var label2 = "Equipped Hat: "
	if category == CATEGORY_TYPE.TRAILS:
		label1 = "Trails"
		label2 = "Equipped Trail: "
	if category == CATEGORY_TYPE.FLOWERS:
		label1 = "Flowers"
		label2 = "Equipped Flower: "
	$Vbox/Label.text = label1
	$Vbox/Label2.text = label2


func _set_current(current : String) -> void:
	current_item = current


func _stock_gallery(persist : Persist, panel : Control) -> void:
	if gallery_stock.size() > 0:
		for g in gallery_stock:
			if is_instance_valid(g):
				g.queue_free()
	gallery_stock.clear()
	for i in inventory:
		if (i.purchase_usd and i.validated) or !i.purchase_usd:
			print("Creating Stock of : ", i.acc_name)
			var new_button = accOption.instantiate()
			new_button._assign_tag(
				i,
				persist.accessories.has(i.acc_name),
				i.acc_name == current_item
			)
			gallery_container.add_child(new_button)
			gallery_stock.append(new_button)
			new_button.tag_selected.connect(panel._tag_selected)
			new_button.gui_input.connect(_on_scroll_gallery_gui_input)
		else:
			print("Cannot Create stock of : ", i.acc_name, " because it isn't validated.")


func _on_scroll_gallery_gui_input(event):
	if event is InputEventMouseButton:
		gallery_held = event.pressed
	if event is InputEventMouseMotion:
		if gallery_held:
			$Vbox/ScrollGallery.scroll_horizontal += (event.relative.x * -1)


func _update_stock_status(persist : Persist) -> void:
	print("Updating Stock Status")
	if gallery_stock.size() > 0:
		for s in gallery_stock:
			s._change_status(
				persist.accessories.has(s.tag.acc_name),
				s.tag.acc_name == current_item
			)


func _set_all_nonselected() -> void:
	if gallery_stock.size() > 0:
		for g in gallery_stock:
			g._set_selected(false)


func _get_item(tag : PriceTag) -> Control:
	var result = null
	if gallery_stock.size() > 0:
		for g in gallery_stock:
			if g.tag == tag:
				result = g
	return result
