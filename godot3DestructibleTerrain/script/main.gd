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

func _split_polygon(clip_polygon: Array,default_quadrant_polygon):
	"""
	Returns two polygons produced by vertically
	splitting split_polygon in half
	"""
	var avg_x = _avg_position(clip_polygon).x
	print(avg_x)
	var left_subquadrant = []
	left_subquadrant.append_array(default_quadrant_polygon)
	left_subquadrant.duplicate()
	left_subquadrant[1] = Vector2(avg_x, left_subquadrant[1].y)
	left_subquadrant[2] = Vector2(avg_x, left_subquadrant[2].y)
	var right_subquadrant = []
	right_subquadrant.append_array(default_quadrant_polygon)
	right_subquadrant.duplicate()
	right_subquadrant[0] = Vector2(avg_x, right_subquadrant[0].y)
	right_subquadrant[3] = Vector2(avg_x, right_subquadrant[3].y)
	var pol1 = Geometry.clip_polygons_2d(left_subquadrant, clip_polygon)[0]
	var pol2 = Geometry.clip_polygons_2d(right_subquadrant, clip_polygon)[0]
	return [pol1, pol2]

func _avg_position(array: Array):
	"""
	Average 2D position in an
	array of positions
	"""
	var sum = Vector2()
	for p in array:
		sum += p
	return sum/len(array)
			
func _physics_process(delta):
	if Input.is_action_just_pressed("click"):
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
						var newPolygons=Transform2D(0, -i.position).xform(clipped_polygons[0])
						i.setPolygon2D(newPolygons)
						i.setPolygon2DTexture(newPolygons)
					2:
						if Geometry.is_polygon_clockwise(clipped_polygons[0]) or \
						Geometry.is_polygon_clockwise(clipped_polygons[1]):  #挖一个洞的时候
#							for x in clipped_polygons:
#								var new=tile.instance()
#								new.position = i.position
#								tiles.add_child(new)
#								var newClipPolygons= Geometry.intersect_polygons_2d(x,i.getPolygon2D())[0]
#								var newPolygons=Transform2D(0, -i.position).xform(x)
#								new.setPolygon2D(newPolygons)
#								new.setPolygon2DTexture(newPolygons)
#								new.setTexture(i.getTexture())
#							var newClipPolygons= Geometry.intersect_polygons_2d(clipped_polygons[0],
#							clipped_polygons[1])
#							if newClipPolygons:
#								var hole=Geometry.intersect_polygons_2d(i.getPolygon2D(),newClipPolygons[0])[0]
#
#								var new=tile.instance()
#								new.position = i.position
#								tiles.add_child(new)
#								var newPolygons=Transform2D(0, -i.position).xform(hole)
#								new.setPolygon2D(newPolygons)
#								new.setPolygon2DTexture(newPolygons)
#								i.free()
							for p in _split_polygon(temp,i.getPolygon2D()):
								var pol1=Geometry.intersect_polygons_2d(p,i.getPolygon2D())[0]
								
								var new=tile.instance()
								new.position = i.position
								tiles.add_child(new)
								var newPolygons=Transform2D(0, -i.position).xform(pol1)
								new.setPolygon2D(newPolygons)
								new.setPolygon2DTexture(newPolygons)
							i.free()
						else:
							var newPolygons1=Transform2D(0, -i.position).xform(clipped_polygons[0])
							i.setPolygon2D(newPolygons1)
							i.setPolygon2DTexture(newPolygons1)
							var new=tile.instance()
							new.position = i.position
							tiles.add_child(new)
							var newPolygons=Transform2D(0, -i.position).xform(clipped_polygons[1])
							new.setPolygon2D(newPolygons)
							new.setPolygon2DTexture(newPolygons)
#							new.setTexture(i.getTexture().duplicate())
					_:
						var newPolygons1=Transform2D(0, -i.position).xform(clipped_polygons[0])
						i.setPolygon2D(newPolygons1)	
						i.setPolygon2DTexture(newPolygons1)
						for x in range(n_clipped_polygons-1):
							var new=tile.instance()
							new.position = i.position
							tiles.add_child(new)
							var newPolygons=Transform2D(0, -i.position).xform(clipped_polygons[x+1])
							new.setPolygon2D(newPolygons)
							new.setPolygon2DTexture(newPolygons)
#							new.setTexture(i.getTexture().duplicate())
							
				
	elif Input.is_action_just_pressed("click_right"):
		for i in ballNum:
			var temp=ball.instance()
			temp.position=get_global_mouse_position() + Vector2(randi()%20,randi()%20)
			balls.add_child(temp)
		
