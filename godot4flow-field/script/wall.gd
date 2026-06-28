extends StaticBody2D

# 墙壁尺寸
var size: Vector2 = Vector2(32, 32)

# 绘制墙壁外观（深灰色矩形）
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO - size / 2, size), Color.DARK_GRAY)