extends Node2D



onready var ani=$ColorRect/ani
var offsetY=64
var timer=0
var outTime=4
var inTime=2.5
var speed=60

func _ready():
	ani.play("default")


func _process(delta):
	timer+=delta
	if timer<outTime:
		ani.position.y-=speed*delta
		if ani.position.y<=0:
			ani.position.y=0
	elif timer<outTime+inTime:
		ani.position.y+=speed*delta
		if ani.position.y>offsetY:
			ani.position.y=offsetY
	else:
		timer=0	
