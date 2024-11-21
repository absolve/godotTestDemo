extends Node2D

var velocity = Vector2.ZERO
var gravity = 200
var bodyList=[] #获取地形
#var polygons=[] #多边形点集合
var radius=40  #半径




func _physics_process(delta):
	velocity.y += gravity * delta
	position += velocity * delta
	rotation = velocity.angle()

	
#爆炸	
func explode():
	var polygons=[] #多边形点集合
	var nb_points = 15
	for i in range(nb_points):
		var angle = lerp(-PI, PI, float(i)/nb_points)
		polygons.push_back(position+Vector2(cos(angle), sin(angle)) * radius)
	
	for i in bodyList:
		if i.has_method('clip'):
			i.clip(polygons)
	#添加一个爆炸效果

	call_deferred("queue_free")


func _on_Area2D_body_entered(body):
	bodyList.append(body)


func _on_Area2D_body_exited(body):
	bodyList.erase(body)


func _on_collision_body_entered(body):
	explode()
	

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
