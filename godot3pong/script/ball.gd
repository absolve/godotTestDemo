extends Area2D

var speed=100
remote var vec=Vector2(-speed,-speed)
remotesync var stop=false

onready var _screen_size = get_viewport_rect().size

func _ready():
	pass



func _physics_process(delta):
	
	if !stop:
		translate(vec* delta)
			
			
	if (position.y<0 and vec.y<0) or (position.y>_screen_size.y and vec.y>0):
		vec.y=-vec.y
		
	if position.x<0 || position.x>_screen_size.x:
		if is_network_master()&&position.x<0:
			Game.emit_signal("update_score",position.x)
		elif !is_network_master() &&position.x>_screen_size.x:
			Game.emit_signal("update_score",position.x)	
		rpc('resetBall')
		

func bounce():
	if vec.x<0:
		vec.x=abs(vec.x)
	else:
		vec.x=-abs(vec.x)
#	vec.y+=randi()%10	
	if Game.isOnline:
		rset('vec',vec)
	
remotesync func setStop():
	stop=true

remotesync func resetBall():
	position.x=_screen_size.x/2


func _on_ball_body_entered(body):
	bounce()
