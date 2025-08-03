extends KinematicBody2D


enum {IDLE,WALK,JUMP,FALL}


var state=IDLE #状态
var vec=Vector2.ZERO
var walkSpeed=600


func _ready():
	pass # Replace with function body.



func _physics_process(delta):
	
	
	is_on_wall()
	
	pass
