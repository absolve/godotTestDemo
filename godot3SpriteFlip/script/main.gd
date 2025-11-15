extends Node2D


var time=9  #倒计时时间

onready var ani=$Node2D/ani
onready var player=$player
onready var timer=$Timer


func _ready():
	OS.center_window()
	ani.play(str(time))
	player.play("filp")
	

#下一个计数
func nextCount():
	time-=1
	if time<0:
		time=9
	ani.play(str(time))	
	player.play("back")
	timer.start()


func _on_Timer_timeout():
	player.play("filp")
