extends KinematicBody2D


var speed=400
puppet var vec=Vector2.ZERO
onready var _screen_size_y = get_viewport_rect().size.y
var isOnline=false

func _ready():
		
	if get_multiplayer().has_network_peer():
		isOnline=true
		print(is_network_master())



func _physics_process(delta):
	if isOnline&&is_network_master():
		if Input.is_action_pressed("move_down"):
			vec=Vector2(0,speed)
		elif Input.is_action_pressed("move_up"):
			vec=Vector2(0,-speed)
		else:
			vec=Vector2.ZERO
		rset("vec",vec)
	translate(vec * delta)
	position.y = clamp(position.y, 16, _screen_size_y - 16)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
