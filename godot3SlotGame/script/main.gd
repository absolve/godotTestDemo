extends Node2D



onready var slot1=$slot
onready var slot2=$slot2
onready var slot3=$slot3

func _ready():
	VisualServer.set_default_clear_color(Color('#000'))
	OS.center_window()
	


func _input(event):
	if event is InputEventKey:
		if event.scancode==KEY_SPACE&&event.is_pressed():
			print('space')
			slot1.currState=Game.state.stop
			pass
	
