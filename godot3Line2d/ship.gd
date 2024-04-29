extends Node2D
#素材 https://ansimuz.itch.io/spaceship-shooter-environment

onready var trail=$Trail
onready var ani=$ani
var speed=150
var velocity=Vector2.ZERO
var angularVel=5

var light=preload("res://Lightning.tscn")
var length=500

func _ready():
	ani.play("default")
	pass # Replace with function body.


func _process(delta):
	velocity=Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		velocity.x=-speed
	
	if Input.is_action_pressed("ui_right"):
		velocity.x=speed
	
	if Input.is_action_pressed("ui_up"):
		velocity.y=-speed
	
	if Input.is_action_pressed("ui_down"):
		velocity.y=speed
	
	if Input.is_action_just_pressed("shoot"):
		shoot()
	
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
		trail.angle=ani.rotation_degrees
		trail.startAdd=true
	else:
		trail.startAdd=false	
	
		
	position+=velocity*delta

func shoot():
	for i in range(3):
		var temp=light.instance()
		add_child(temp)
		var start=global_position
		var end=global_position+Vector2.RIGHT.rotated(ani.rotation)*length
#		print(start,end)
		temp.add(start,end)
