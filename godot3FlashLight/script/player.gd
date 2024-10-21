extends KinematicBody2D

var speed = 5
var movement = Vector2(0, 0)
onready var light=$Light2D


func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	movement = Vector2(0, 0)
	light.look_at(get_global_mouse_position())
	if Input.is_action_pressed("ui_up"):
		movement.y -= speed
	if Input.is_action_pressed("ui_down"):
		movement.y += speed
	
	if Input.is_action_pressed("ui_left"):
		movement.x -= speed
	if Input.is_action_pressed("ui_right"):
		movement.x += speed
		
	move_and_collide(movement)
	
