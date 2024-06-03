extends KinematicBody2D

var velocity=Vector2.ZERO	#速度
var angularVel=5
var speed=200	#移动速度
var rayCount=36 #射线数量
var ray_directions = []
var rayLength=80  #射线长度
var fireTimer=0	#开火定时器
var fireDelay=100

onready var barrel=$barrel
onready var ani=$ani

var bullet=preload("res://scene/bullet.tscn")





func _physics_process(delta):
	
	barrel.look_at(get_global_mouse_position())
	velocity=Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		velocity.x=-speed
	if Input.is_action_pressed("ui_right"):
		velocity.x=speed
	if Input.is_action_pressed("ui_up"):
		velocity.y=-speed
	if Input.is_action_pressed("ui_down"):
		velocity.y=speed
	if Input.is_action_pressed("shoot"):
		fire()
						
	move_and_collide(velocity*delta)					
	animation()

	
func animation():
	if velocity!=Vector2.ZERO:
		var angle=round(rad2deg(velocity.angle()))
		if angle<0:
			angle=360-abs(angle)
		if 	abs(angle-ani.rotation_degrees)>180:#变化的幅度超过180 就把angle增加360或者较少360
			if angle<ani.rotation_degrees:
				angle+=360
			else:
				angle-=360
		
		if ani.rotation_degrees!=angle:
			if ani.rotation_degrees>angle:
				if ani.rotation_degrees-angularVel<angle:
					ani.rotation_degrees=angle
				else:
					ani.rotation_degrees-=angularVel
			if ani.rotation_degrees<angle:		
				if ani.rotation_degrees+angularVel>angle:
					ani.rotation_degrees=angle
				else:
					ani.rotation_degrees+=angularVel		
		ani.play("default")
	else:
		ani.stop()
	
func fire():
	if Time.get_ticks_msec()-fireTimer>fireDelay:
		fireTimer=Time.get_ticks_msec()
		var temp=bullet.instance()
		temp.position=position+Vector2(10,0).rotated(barrel.rotation)
		temp.velocity=Vector2(400,0).rotated(barrel.rotation)
		get_parent().add_child(temp)
