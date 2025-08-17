extends Area2D

#方向
enum Dir{
	UP,DOWN,LEFT,RIGHT
}
var speed=380
var dir=Dir.UP
const cellSize=16
var mapSize=Vector2(cellSize*26,cellSize*26)
var vec=Vector2.ZERO
var explode=preload("res://scene/explosion.tscn")
var ownId=0
onready var sprite=$Sprite
onready var shape=$shape
var objType=Game.objType.BULLET


func _ready():
	if dir==Dir.UP:
		sprite.flip_v=true
		vec=Vector2(0,-speed)
	elif dir==Dir.DOWN:
		vec=Vector2(0,speed)
	elif dir==Dir.LEFT:
		vec=Vector2(-speed,0)
		sprite.rotation_degrees=90
		shape.rotation_degrees=90
	elif dir==Dir.RIGHT:
		vec=Vector2(speed,0)
		sprite.rotation_degrees=-90
		shape.rotation_degrees=-90

#爆炸效果
func addexplode():
	visible=false
	set_deferred('monitorable',false)
	set_deferred('monitoring',false)
	set_physics_process(false)
	var temp = explode.instance()
	temp.position=position
	Game.addObj(temp)
	queue_free()


func _physics_process(delta):
	position+=vec*delta
	if position.x<0||position.x>mapSize.x:
		addexplode()	
	if position.y<0||position.y>mapSize.y:
		addexplode()	
	

func _on_bullet_area_entered(area):
	if area.get_instance_id()==ownId:
		return	
	if area.get('objType')==Game.objType.ENEMY:
		addexplode()		
