extends Area2D

#方向
enum Dir{
	UP,DOWN,LEFT,RIGHT
}


onready var ani=$ani
var vec=Vector2.ZERO
var dir=Dir.UP #方向
var speed = 70  #移动速度
