extends KinematicBody2D


var vec=Vector2.ZERO
var state=Game.playerState.IDLE
var dir=Game.direction.LEFT
var walkSpeed=100

onready var ani=$ani


func _ready():

	pass


func _physics_process(delta):
	if state==Game.playerState.IDLE:
		var v=Input.get_axis("move_left","move_right")
		if v!=0:
			state=Game.playerState.WALK
		animation('idle')
	elif state==Game.playerState.WALK:
		
		if Input.is_action_pressed("move_left"):
			dir=Game.direction.LEFT
			vec.x=-walkSpeed
		elif Input.is_action_pressed("move_right"):
			dir=Game.direction.RIGHT
			vec.x=walkSpeed
		
		animation('walk')
	vec=move_and_slide(vec,Vector2.UP)


func animation(type):
	if type=='idle':
		ani.play("idle")
	elif type=='walk':
		ani.play("walk")
	
	if dir==Game.direction.LEFT:
		ani.flip_h=true
	else:
		ani.flip_h=false
