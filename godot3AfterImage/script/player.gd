extends KinematicBody2D


var vec=Vector2.ZERO
var state=Game.playerState.IDLE
var dir=Game.direction.RIGHT
var walkSpeed=200
var gravity=600  #重力
var jumpSpeed=400 # 跳跃力 

onready var ani=$ani


func _ready():

	pass


func _physics_process(delta):
	vec.y+=gravity*delta
	if state==Game.playerState.IDLE:
		var v=Input.get_axis("move_left","move_right")
		if v!=0:
			state=Game.playerState.WALK
			
		if Input.is_action_pressed("jump"):
			vec.y=-jumpSpeed
			state=Game.playerState.INAIR	
		animation('idle')
	elif state==Game.playerState.WALK:
		
		if Input.is_action_pressed("move_left"):
			dir=Game.direction.LEFT
			vec.x=-walkSpeed
		elif Input.is_action_pressed("move_right"):
			dir=Game.direction.RIGHT
			vec.x=walkSpeed
		else:
			vec.x=0
		
		if Input.is_action_pressed("jump"):
			vec.y=-jumpSpeed
			state=Game.playerState.INAIR

		
		if vec.x==0&&is_on_floor():
			state=Game.playerState.IDLE
			
		animation('walk')
	elif state==Game.playerState.INAIR:
		if Input.is_action_pressed("move_left"):
			dir=Game.direction.LEFT
			vec.x=-walkSpeed
		elif Input.is_action_pressed("move_right"):
			dir=Game.direction.RIGHT
			vec.x=walkSpeed
		
		if is_on_floor():
			state=Game.playerState.WALK	
		if vec.y<0:
			animation('jump')	
		else:
			animation('fall')		
	vec=move_and_slide(vec,Vector2.UP)


func animation(type):
	if dir==Game.direction.LEFT:
		ani.flip_h=true
	else:
		ani.flip_h=false
	if type=='idle'||type=='walk':
		ani.play(type)
	elif type=='jump'||type=='fall':
		ani.play(type)
#		print(Engine.get_physics_frames())
		if Engine.get_physics_frames() % 6 == 0:
#			AfterImage.addImage(ani.frames.get_frame(type,ani.frame),position,ani.scale,ani.flip_h)
#			AfterImage.addBlackImage(ani.frames.get_frame(type,ani.frame),position,ani.scale,ani.flip_h)
			AfterImage.addBlueImage(ani.frames.get_frame(type,ani.frame),position,ani.scale,ani.flip_h)
#			AfterImage.addSkeletonImage(ani.frames.get_frame(type,ani.frame),position,ani.scale,ani.flip_h)	
