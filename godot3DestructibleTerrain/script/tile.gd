extends StaticBody2D

export var textureImg="" #纹理图片路径
onready var polygon2D=$CollisionPolygon2D
onready var polygon2DTexture=$Polygon2D

func setPolygon2D(array):
	polygon2D.polygon=array

func setPolygon2DTexture(array):
	polygon2DTexture.polygon=array

func setTexture(texture):
	polygon2DTexture.texture=texture
	
func getTexture():
	return polygon2DTexture.texture

#获取当前多边形数组 需要加上位置信息
func getPolygon2D():
	return Transform2D(0,position).xform(polygon2D.polygon)
	
#加载图片
func loadTexture():
	var texture=load(textureImg)
	polygon2DTexture.texture=texture

#裁剪多边形
func clip(polygon):
	if Geometry.intersect_polygons_2d(getPolygon2D(),polygon):
		var clipped_polygons=Geometry.clip_polygons_2d(getPolygon2D(),polygon)
		var clippedPolygonsSize = len(clipped_polygons)
		match clippedPolygonsSize:
			0:
				call_deferred("queue_free")
			1:
				var newPolygons=Transform2D(0, -position).xform(clipped_polygons[0])	
				call_deferred('setPolygon2D',newPolygons)
				call_deferred('setPolygon2DTexture',newPolygons)
#				setPolygon2D(newPolygons)
#				setPolygon2DTexture(newPolygons)
			2:
				if Geometry.is_polygon_clockwise(clipped_polygons[0]) or \
						Geometry.is_polygon_clockwise(clipped_polygons[1]):  #挖一个洞的时候，目前没有好的办法
					pass
				else:
					var newPolygons1=Transform2D(0, -position).xform(clipped_polygons[0])	
#					setPolygon2D(newPolygons1)
#					setPolygon2DTexture(newPolygons1)
					call_deferred('setPolygon2D',newPolygons1)
					call_deferred('setPolygon2DTexture',newPolygons1)
					#新增其他的图形
					var new =load("res://scene/tile.tscn").instance()
					new.position = position
					new.textureImg=textureImg
					get_parent().add_child(new)
					var newPolygons=Transform2D(0, position).xform(clipped_polygons[1])
					new.call_deferred('setPolygon2D',newPolygons)
					new.call_deferred('setPolygon2DTexture',newPolygons)
					new.call_deferred('loadTexture')
#					new.setPolygon2D(newPolygons)
#					new.setPolygon2DTexture(newPolygons)
#					new.loadTexture()
			_:
				var newPolygons1=Transform2D(0, -position).xform(clipped_polygons[0])	
#				setPolygon2D(newPolygons1)
#				setPolygon2DTexture(newPolygons1)
				call_deferred('setPolygon2D',newPolygons1)
				call_deferred('setPolygon2DTexture',newPolygons1)
				for x in range(clippedPolygonsSize-1):  #添加新的多边形
					var new =load("res://scene/tile.tscn").instance()
					new.position = position
					new.textureImg=textureImg
					get_parent().add_child(new)
					var newPolygons=Transform2D(0, -position).xform(clipped_polygons[x+1])
					new.call_deferred('setPolygon2D',newPolygons)
					new.call_deferred('setPolygon2DTexture',newPolygons)
					new.call_deferred('loadTexture')
#					new.setPolygon2D(newPolygons)
#					new.setPolygon2DTexture(newPolygons)
#					new.loadTexture()
					
