extends KinematicBody2D


enum {IDLE,WALK,JUMP,FALL,INAIR}
enum {LEFT,Right}

var state=IDLE #状态
var vec=Vector2.ZERO
#var walkSpeed=600
var dir=Right	#方向
var gravity=500  #重力
var acceleration=300
var maxXVel=300
var aniSpeed=220 #动画速度
var jumpSpeed=300

onready var ani=$ani

func _ready():
	pass # Replace with function body.



func _physics_process(delta):
	vec.y+=gravity*delta
	if state==IDLE:
#		vec=Vector2.ZERO
		if Input.is_action_pressed("move_left"):
			state=WALK
			dir=LEFT
		elif Input.is_action_pressed("move_right"):
			state=WALK
			dir=Right	
		if Input.is_action_pressed("jump"):
			vec.y=-jumpSpeed
			state=INAIR
			return	
		animation('idle')	
	elif state==WALK:
		
		if Input.is_action_pressed("jump"):
			vec.y=-jumpSpeed
			state=INAIR
			return
		
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
					vec.x-=acceleration	*delta
				else:
					vec.x=0
					state=IDLE
		if vec.x>0||vec.x<0: #调整动画速度
			ani.speed_scale=1+abs(vec.x)/aniSpeed
		animation('walk')	
	elif state==INAIR: #在空中
		if vec.y<0:
			animation('jump')
		else:
			animation('fall')
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
		
		if is_on_floor():
			state=WALK	
		
					
	vec = move_and_slide(vec,Vector2.UP)
		
				
func animation(type):
	ani.play(type)
		
	if dir==Right:
		ani.flip_h=false
	elif dir==LEFT:
		ani.flip_h=true	
