extends Node2D

var font: Font


func _ready() -> void:
	font = ThemeDB.fallback_font


func _draw() -> void:
	draw_rect(Rect2(Vector2(-16, -16), Vector2(32, 32)), Color("#3ad18c"), false, 3.0)
	draw_circle(Vector2.ZERO, 9.0, Color("#3ad18c"))
	draw_string(font, Vector2(-4, 5), "P", HORIZONTAL_ALIGNMENT_LEFT, -1, 12,
			Color("#10221a"))
