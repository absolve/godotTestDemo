extends StaticBody2D

var size:Vector2=Vector2(32,32)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO-size/2,size),Color.DARK_GRAY)
