extends StaticBody2D


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
	pass
