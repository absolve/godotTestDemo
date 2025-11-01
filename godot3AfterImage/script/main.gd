extends Node2D


onready var camera=$Camera2D
onready var player=$player

func _ready():
	OS.center_window()
	

func _physics_process(delta):
	
	if player.vec.x>0&&player.position.x>camera.get_camera_screen_center().x:
		camera.position.x+=player.vec.x*delta
	
	
	if player.vec.x<0&&player.position.x<camera.get_camera_screen_center().x:
		camera.position.x-=abs(player.vec.x*delta)

