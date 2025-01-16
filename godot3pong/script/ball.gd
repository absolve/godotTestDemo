extends KinematicBody2D

var speed=100
master var vec=Vector2(-speed,-speed)
remotesync var stop=false

onready var _screen_size = get_viewport_rect().size

func _ready():
	pass



func _physics_process(delta):
	
	if !stop:
		var collision =move_and_collide(vec*delta)
		if collision:
			bounce()
			
			
	if (position.y<0 and vec.y<0) or (position.y>_screen_size.y and vec.y>0):
		if vec.y<0:
			vec=vec.bounce(Vector2.DOWN)
		else:
			vec=vec.bounce(Vector2.UP)
	if position.x<0 || position.x>_screen_size.x:
		position.x=_screen_size.x/2


func bounce():
	if vec.x<0:
		vec.x=abs(vec.x)
	else:
		vec.x=-abs(vec.x)
	vec.y+=randi()%10	
	if Game.isOnline:
		rset('vec',vec)
	
remotesync func setStop():
	stop=true

func resetBall():
	
	pass
