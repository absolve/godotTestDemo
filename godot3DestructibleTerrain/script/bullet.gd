extends Node2D

var velocity = Vector2.ZERO
var gravity = 0.0
var bodyList=[] #获取地形


func _ready():
	pass

func _physics_process(delta):
	
	pass
	
#爆炸	
func explode():
	
	pass	


func _on_Area2D_body_entered(body):
	bodyList.append(body)


func _on_Area2D_body_exited(body):
	bodyList.erase(body)


func _on_collision_body_entered(body):
	pass # Replace with function body.
