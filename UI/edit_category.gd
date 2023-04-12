extends Control

enum CATEGORY_TYPE {HATS, TRAILS, FLOWERS}

@export var category : CATEGORY_TYPE
@export var inventory : Array[PriceTag] = []

@onready var current_icon = $Vbox/Current/CurrentIcon
@onready var current_label = $Vbox/Current/CurrentLabel
@onready var gallery_container = $Vbox/ScrollGallery/Gallery

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
	if inventory.size() > 0:
		_stock_gallery()


func _stock_gallery():
	pass


func _set_current(current : String) -> void:
	print("Category: ", category, " setting current of : ", current)


func _on_scroll_gallery_gui_input(event):
	if event is InputEventMouseButton:
		gallery_held = event.pressed
	if event is InputEventMouseMotion:
		if gallery_held:
			$Vbox/ScrollGallery.scroll_horizontal += (event.relative.x * -1)
