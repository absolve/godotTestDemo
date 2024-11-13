extends Node2D



onready var img=$Sprite
onready var cpolygon2D=$StaticBody2D/CollisionPolygon2D

func _ready():
	var bm = BitMap.new()
	bm.create_from_image_alpha(img.texture.get_data())
	for i in range(img.texture.get_height()):
		for y in range(100):
			bm.set_bit(Vector2(y,i),false)
	var texture = ImageTexture.new()
	texture.create_from_image(bm.convert_to_image())
	img.texture=texture
#	print(img.texture.get_width())
#	var rect = Rect2(0,0,img.texture.get_width(),img.texture.get_height())
#	var my_array = bm.opaque_to_polygons(rect)
#	print(my_array.size())
#	var my_polygon = Polygon2D.new()
#	my_polygon.set_polygons(my_array)
#	cpolygon2D.set_polygon(my_polygon.polygon)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
