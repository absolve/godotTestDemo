extends Node2D


func _ready():
	OS.center_window()
	VisualServer.set_default_clear_color('#000')
	Game.mainScene=self
