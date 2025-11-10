extends Node2D


var time=9  #倒计时时间

onready var ani=$ani
onready var player=$player

func _ready():
	ani.play(str(time))



#下一个计数
func nextCount():
	time-=1
	if time<=0:
		time=0
		
		

