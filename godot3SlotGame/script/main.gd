extends Node2D



onready var slot1=$slot


func _ready():
	VisualServer.set_default_clear_color(Color('#000'))
	OS.center_window()
	


func _input(event):
	if event is InputEventKey:
		if event.scancode==KEY_SPACE&&event.is_pressed():
			print('space')
			pass
	
