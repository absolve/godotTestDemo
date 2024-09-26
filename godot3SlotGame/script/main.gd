extends Node2D



onready var slot1=$slot
onready var slot2=$slot2
onready var slot3=$slot3
onready var ani=$ani
onready var light1=$light1
onready var light2=$light2
onready var light3=$light3
onready var hand=$hand
onready var timer=$Timer

var index=0  #索引
var state=Game.gameState.idle

func _ready():
	VisualServer.set_default_clear_color(Color('#000'))
	OS.center_window()
	Game.connect("getResult",self,"getResult")


func _input(event):
	if event is InputEventKey:
		if event.scancode==KEY_SPACE&&event.is_pressed():
			print('space')
			if state==Game.gameState.idle:
				slot1.start()
				slot2.start()
				slot3.start()
				
				ani.play("default")
				timer.start()
				state=Game.gameState.wait
			elif state==Game.gameState.start:
				if index==0:
					if slot1.currState==Game.state.scroll:
						slot1.currState=Game.state.stop
						index+=1
						light1.visible=false
						hand.position.x=402
				elif index==1:
					if slot2.currState==Game.state.scroll:
						slot2.currState=Game.state.stop
						index+=1
						light2.visible=false
						hand.position.x=474
				elif index==2:
					if slot3.currState==Game.state.scroll:
						slot3.currState=Game.state.stop
						index+=1
						light3.visible=false
						hand.visible=false

func getResult(type):
	print('getResult ',type)


func _on_Timer_timeout():
	light1.visible=true
	light2.visible=true
	light3.visible=true
	hand.visible=true
	state=Game.gameState.start
