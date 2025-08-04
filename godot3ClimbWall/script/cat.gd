extends KinematicBody2D


enum {IDLE,WALK,JUMP,FALL}
enum {LEFT,Right}

var state=IDLE #状态
var vec=Vector2.ZERO
var walkSpeed=600
var dir=Right
var gravity=0  #重力
var acceleration=240
var maxXVel=180

onready var ani=$ani

func _ready():
	pass # Replace with function body.



func _physics_process(delta):
	vec=Vector2.ZERO
	if state==IDLE:
		if Input.is_action_pressed("move_left"):
			state=WALK
			dir=LEFT
		elif Input.is_action_pressed("move_right"):
			state=WALK
			dir=Right	
	elif state==WALK:
		if Input.is_action_pressed("move_left"):
			dir=LEFT
			if vec.x>-maxXVel:
				vec.x-=acceleration*delta
			else:
				vec.x=-maxXVel
		elif Input.is_action_pressed("move_right"):
			dir=Right	
			if vec.x<maxXVel:
				vec.x+=acceleration*delta
			else:
				vec.x=maxXVel
		else:
			if dir==LEFT:
				if vec.x<0:
					vec.x+=acceleration*delta
				else:
					vec.x=0
					state=IDLE
			else:
				if vec.x>0:
					vec.x-=acceleration*delta		
				else:
					vec.x=0
					state=IDLE
		vec = move_and_slide(vec)
		
				
func animation():
	if state==IDLE:
		ani.play("idle")
	elif state==WALK:
		ani.play("walk")
		
	if dir==Right:
		ani.flip_h=false
	elif dir==LEFT:
		ani.flip_h=true	
