extends Node2D



var spritePath="res://sprite/battle_city.png"
var tile=preload("res://scene/tile.tscn")
var carve_radius = 40  #角度

onready var tiles=$tiles

func _ready():
	OS.center_window()
#	var bm = BitMap.new()
#	bm.create_from_image_alpha(img.texture.get_data())
#	for i in range(img.texture.get_height()):
#		for y in range(100):
#			bm.set_bit(Vector2(y,i),false)
#	var texture = ImageTexture.new()
#	texture.create_from_image(bm.convert_to_image())
#	img.texture=texture

#	print(img.texture.get_width())
#	var rect = Rect2(0,0,img.texture.get_width(),img.texture.get_height())
#	var my_array = bm.opaque_to_polygons(rect)
#	print(my_array.size())
#	var my_polygon = Polygon2D.new()
#	my_polygon.set_polygons(my_array)
#	cpolygon2D.set_polygon(my_polygon.polygon)
#	var temp=create_polygon_from_sprite(img)
#	print(temp)

	loadPolygonFromImg(spritePath)
	pass

# The sprite parameter must be a Sprite node.
func create_polygon_from_sprite(sprite):
	# Get the sprite's texture.
	var texture = sprite.texture
	# Get the sprite texture's size.
	var texture_size = sprite.texture.get_size()
	# Get the image from the sprite's texture.
	var image = texture.get_data()

	# Create a new bitmap.
	var bitmap = BitMap.new()
	# Create the bitmap from the image. We set the minimum alpha threshold.
	bitmap.create_from_image_alpha(image, 0.01) # 0.1 (default threshold).
	# Get the rect of the bitmap.
	var bitmap_rect = Rect2(Vector2(0, 0), bitmap.get_size())
	# Grow the bitmap if you need (we don't need it in this case).
#	bitmap.grow_mask(0, rect) # 2
	# Convert all the opaque parts of the bitmap into polygons.
	var polygons = bitmap.opaque_to_polygons(bitmap_rect, 0) # 2 (default epsilon).

	# Check if there are polygons.
	if polygons.size() > 0:
		# Loop through all the polygons.
		for i in range(polygons.size()):
			# Create a new 'Polygon2D'.
			var polygon = Polygon2D.new()
			# Set the polygon.
			polygon.polygon = polygons[i]
			# Set the texture.
			polygon.texture = texture

			# Check if the sprite is centered to get the proper position.
			if sprite.centered:
				polygon.position = sprite.position - (texture_size / 2)
			else:
				polygon.position = sprite.position

			# Take the sprite's scale into account and apply it to the position.
			polygon.scale = sprite.scale
			polygon.position *= polygon.scale

			polygon.name = "poly_sprite"

			return polygon
	else:
		return false


func loadPolygonFromImg(sprite):
	var texture = load(sprite)
	var image = texture.get_data()

	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image, 0.01)
	var bitmap_rect = Rect2(Vector2(0, 0), bitmap.get_size())
	var polygons = bitmap.opaque_to_polygons(bitmap_rect, 0) 
	print(polygons.size())
	if polygons.size() > 0:	
		for i in polygons:	
			var polygon = Polygon2D.new()
			polygon.polygon=i
			polygon.texture=texture
			polygon.position = Vector2.ZERO
			add_child(polygon)
			var temp=tile.instance()
#			temp.position = Vector2.ZERO
			tiles.add_child(temp)
			temp.setPolygon2D(i)

#鼠标圆
func mouseCircle():
	var nb_points = 15
	var pol = []
	for i in range(nb_points):
		var angle = lerp(-PI, PI, float(i)/nb_points)
		pol.push_back(get_global_mouse_position() + Vector2(cos(angle), sin(angle)) * carve_radius)
	return pol
			
func _physics_process(delta):
	if Input.is_action_pressed("click"):
		var temp=mouseCircle()
		for i in tiles.get_children():
			var clipped_polygons=Geometry.clip_polygons_2d(i.polygon2D.polygon,temp)
			var n_clipped_polygons = len(clipped_polygons)
			match n_clipped_polygons:
				0:
					i.free()	
				1:
					i.setPolygon2D(clipped_polygons[0])
				2:
					pass
				_:
					i.setPolygon2D(clipped_polygons[0])	
