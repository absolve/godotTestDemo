extends KinematicBody2D


var velocity=Vector2.ZERO	#速度
var speed=200
export var angularVel=5   #旋转速度

onready var ani=$ani
onready var barrel=$barrel


func _ready():
	pass # Replace with function body.


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
				
		if ani.rotation_degrees!=angle :
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
	else:
		ani.stop()
