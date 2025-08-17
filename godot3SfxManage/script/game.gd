extends Node


var mainScene

#对象类型
enum objType{
	PLAYER=1001,ENEMY,BULLET
}

func _ready():
	pass # Replace with function body.

func addObj(obj):
	if mainScene:
		mainScene.add_child(obj)
