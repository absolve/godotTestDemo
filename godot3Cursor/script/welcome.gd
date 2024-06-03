extends Node2D

func _ready():
	VisualServer.set_default_clear_color(Color('#9c9c9c'))
	OS.center_window()

func _on_Button_pressed():
	set_process_input(false)
	get_tree().change_scene("res://scene/main.tscn")
	set_process_input(true)
	
