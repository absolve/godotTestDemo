extends Node2D


var mapSize:Vector2=Vector2(32,24)
var cellSize:Vector2=Vector2(32,32)

#目标点距离   key 为x-y  value为距离
var distance_field:Dictionary={}
#流场 指向最近目标的方向向量  value为方向
var flow_field:Dictionary={}

func _ready() -> void:
	
	pass

#计算流场
func computeFields(_target:Vector2):
	
	pass


func _draw() -> void:
	for i in range(mapSize.x):
		draw_line(Vector2(i*cellSize.x,0),Vector2(i*cellSize.x,mapSize.y*cellSize.y),Color.WHITE,1)
	
	for i in range(mapSize.y):
		draw_line(Vector2(0,i*cellSize.y),Vector2(mapSize.x*cellSize.x,i*cellSize.y),Color.WHITE,1)

	
