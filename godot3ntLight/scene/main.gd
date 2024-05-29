extends Node2D


onready var player=$player
onready var rect=$CanvasLayer/ColorRect
onready var _camera=$Camera2D

var playerPos
onready var screenSize=get_viewport().size
var offset=0.0
var timer=0
var delay=50

func _ready():
	OS.center_window()


func _physics_process(delta):
	offset =rand_range(-0.01,0.01)
	#摄像机跟随玩家移动
	if player!=null and is_instance_valid(player):
		if player.velocity.x>0&& player.position.x>_camera.get_camera_screen_center().x:
				_camera.position.x+=player.velocity.x*delta
		if player.velocity.x<0 &&player.position.x<_camera.get_camera_screen_center().x&&\
			_camera.position.x>0: 
			if _camera.position.x<0:
				_camera.position.x=0
			else:
				_camera.position.x-=abs(player.velocity.x*delta)

		#上下移动
		if player.velocity.y>0&&player.position.y>_camera.get_camera_screen_center().y:
			_camera.position.y+=player.velocity.y*delta
		if player.velocity.y<0 &&player.position.y<_camera.get_camera_screen_center().y&&\
			_camera.position.y>0: 
			if _camera.position.y<0:
				_camera.position.y=0
			else:
				_camera.position.y-=abs(player.velocity.y*delta)
	
	playerPos=(player.global_position-_camera.position)/screenSize
#	print(playerPos)
	rect.material.set_shader_param("player_position",playerPos)
	timer+=1
	if timer>delay:
		delay=0
		offset =rand_range(-0.0024,0.0024)
		rect.material.set_shader_param("outer_radius",0.25+offset)
		rect.material.set_shader_param("inner_radius",0.1+offset)
