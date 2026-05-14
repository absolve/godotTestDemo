extends CharacterBody2D

var size:Vector2=Vector2(32,32)
var speed=100


func _physics_process(_delta: float) -> void:
	var dir=FlowField.getFlowDir(global_position)
	#print(dir)
	if global_position.distance_to(FlowField.target*FlowField.cellSize+FlowField.cellSize/2)<FlowField.cellSize.x:
		
		pass
	elif dir!=null :
		velocity =dir.normalized()*speed
		move_and_slide()


func _draw() -> void:
	
	draw_rect(Rect2(Vector2.ZERO-size/2,size),Color.BLACK)
