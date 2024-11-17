extends StaticBody2D


onready var polygon2D=$CollisionPolygon2D


func setPolygon2D(array):
	polygon2D.polygon=array

