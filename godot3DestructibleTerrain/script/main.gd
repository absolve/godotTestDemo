extends Node2D



var spritePath="res://sprite/battle_city.png"
var bgPath="res://sprite/Background.png"
var tile=preload("res://scene/tile.tscn")
var ball=preload("res://scene/ball.tscn")
var carve_radius = 20  #半径
var ballNum=5 #球的数量

onready var tiles=$tiles
onready var balls=$balls

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

#	loadPolygonFromImg(spritePath)
	loadPolygonFromImg(bgPath,Vector2(0,420))
#	loadPolygonFromImg(bgPath,Vector2(320,420))
#	loadPolygonFromImg(bgPath,Vector2(640,420))
	
	
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

#从图片中载入
func loadPolygonFromImg(sprite,pos:Vector2=Vector2.ZERO):
	var texture = load(sprite)
	var image = texture.get_data()

	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image, 0.01)
	var bitmap_rect = Rect2(Vector2(0, 0), bitmap.get_size())
	var polygons = bitmap.opaque_to_polygons(bitmap_rect, 0) 
	print(polygons.size())
	if polygons.size() > 0:	
		for i in polygons:	
#			var polygon = Polygon2D.new()
#			polygon.polygon=i
#			polygon.texture=texture
#			polygon.position = Vector2.ZERO
#			add_child(polygon)
			var temp=tile.instance()
			temp.position = pos
			tiles.add_child(temp)
			temp.setPolygon2D(i)
			temp.setPolygon2DTexture(i)
			temp.setTexture(texture)
#	var pos1=Transform2D(0, Vector2(10,10)).xform(polygons[0])
#	print(pos1)
			
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
#		print(get_global_mouse_position())
#		var mouse_polygon = Transform2D(0, get_global_mouse_position()).xform(temp)
		for i in tiles.get_children():
			if Geometry.intersect_polygons_2d(i.getPolygon2D(),temp): #判断多边形是否相交
				var clipped_polygons=Geometry.clip_polygons_2d(i.getPolygon2D(),temp)
				var n_clipped_polygons = len(clipped_polygons)
				match n_clipped_polygons:
					0:
						i.free()	
					1:
						i.setPolygon2D(clipped_polygons[0])
						i.setPolygon2DTexture(clipped_polygons[0])
					2:
						if Geometry.is_polygon_clockwise(clipped_polygons[0]) or \
						Geometry.is_polygon_clockwise(clipped_polygons[1]):
							for x in n_clipped_polygons:
								var new=tile.instance()
#								new.position = i.position
								tiles.add_child(new)
								new.setPolygon2D(clipped_polygons[x])
								new.setPolygon2DTexture(clipped_polygons[x])
								new.setTexture(i.getTexture())
							i.free()
						else:
							i.setPolygon2D(clipped_polygons[0])
							i.setPolygon2DTexture(clipped_polygons[0])
							var new=tile.instance()
							new.position = i.position
							tiles.add_child(new)
							new.setPolygon2D(clipped_polygons[1])
							new.setPolygon2DTexture(clipped_polygons[1])
#							new.setTexture(i.getTexture().duplicate())
					_:
						i.setPolygon2D(clipped_polygons[0])	
						i.setPolygon2DTexture(clipped_polygons[0])
						for x in range(n_clipped_polygons-1):
							var new=tile.instance()
#							new.position = i.position
							tiles.add_child(new)
							new.setPolygon2D(clipped_polygons[x+1])
							new.setPolygon2DTexture(clipped_polygons[x+1])
							new.setTexture(i.getTexture().duplicate())
							
				
	elif Input.is_action_just_pressed("click_right"):
		for i in ballNum:
			var temp=ball.instance()
			temp.position=get_global_mouse_position() + Vector2(randi()%20,randi()%20)
			balls.add_child(temp)
		
