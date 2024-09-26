extends Node2D



onready var slot1=$slot
onready var slot2=$slot2
onready var slot3=$slot3
onready var ani=$ani
var index=0  #索引

func _ready():
	VisualServer.set_default_clear_color(Color('#000'))
	OS.center_window()
	Game.connect("getResult",self,"getResult")


func _input(event):
	if event is InputEventKey:
		if event.scancode==KEY_SPACE&&event.is_pressed():
			print('space')
			if index==0:
				if slot1.currState==Game.state.scroll:
					slot1.currState=Game.state.stop
					index+=1
			elif index==1:
				if slot2.currState==Game.state.scroll:
					slot2.currState=Game.state.stop
					index+=1
			elif index==2:
				if slot3.currState==Game.state.scroll:
					slot3.currState=Game.state.stop
					index+=1

func getResult(type):
	print('getResult',type)
