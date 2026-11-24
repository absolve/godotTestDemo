extends Node2D

var font: Font


func _ready() -> void:
	font = ThemeDB.fallback_font


func _draw() -> void:
	draw_circle(Vector2.ZERO, 10.0, Color("#f27655"))
	draw_arc(Vector2.ZERO, 10.0, 0.0, TAU, 24, Color("#ffd2bd"), 1.5)
	draw_string(font, Vector2(-4, 4), "Z", HORIZONTAL_ALIGNMENT_LEFT, -1, 10,
			Color("#291712"))
