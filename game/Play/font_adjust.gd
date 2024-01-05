extends Node

@export var bee_theme : Theme
@export var bee_sub_theme : Theme

@export var avenir_font : Font
@export var metro_font : Font

func _ready() -> void:
	if OS.has_feature("android"):
		bee_theme.default_font = metro_font
		bee_sub_theme.default_font = metro_font
