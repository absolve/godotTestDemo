extends KinematicBody2D


var velocity=Vector2.ZERO	#速度
var speed=110	#移动速度

onready var ani=$ani

func _ready():
	pass # Replace with function body.


func _physics_process(delta):
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
		ani.play("walik")
		if velocity.x<0:
			ani.flip_h=true
		else:
			ani.flip_h=false	
	else:
		ani.play("default")
