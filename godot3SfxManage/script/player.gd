extends "res://script/tank.gd"


onready var shootTimer=$shootTimer

export var playerId=0
var keymap={"up":0,"down":0,"left":0,"right":0,'shoot':0}
const cellSize=16	#每个格子的大小是16px
var mapSize=Vector2(cellSize*26,cellSize*26)
var tankSize=28
var canShoot=true #可以发射子弹
var bullets=[] #保存子弹素组
var bulletMax=1	#发射最大子弹数
var bullet=preload("res://scene/bullet.tscn")
var objType=Game.objType.PLAYER

func _ready():
	if playerId==0:
		keymap["up"]="p1_up"
		keymap["down"]="p1_down"
		keymap["left"]="p1_left"
		keymap["right"]="p1_right"
		keymap["shoot"]="p1_shoot"
	elif playerId==1:
		keymap["up"]="p2_up"
		keymap["down"]="p2_down"
		keymap["left"]="p2_left"
		keymap["right"]="p2_right"
		keymap["shoot"]="p2_shoot"	
		ani.material.set_shader_param('ischange',true)

func _physics_process(delta):
	if Input.is_action_pressed(keymap["down"]):	
		vec=Vector2(0,speed)
		dir=Dir.DOWN
	elif Input.is_action_pressed(keymap["up"]):
		vec=Vector2(0,-speed)
		dir=Dir.UP
	elif Input.is_action_pressed(keymap["left"]):
		vec=Vector2(-speed,0)
		dir=Dir.LEFT
	elif Input.is_action_pressed(keymap["right"]):
		vec=Vector2(speed,0)
		dir=Dir.RIGHT
	else:
		vec=Vector2.ZERO	
		
	if Input.is_action_pressed(keymap["shoot"]):
		fire()


	animation(dir,vec)		
	position+=vec*delta
	#调整一下位置
	if position.x<=tankSize/2:
		position.x=tankSize/2
	if position.x>=mapSize.x-tankSize/2:	
		position.x=mapSize.x-tankSize/2

	if position.y<=tankSize/2:
		position.y=tankSize/2
	if position.y>=mapSize.y-tankSize/2:	
		position.y=mapSize.y-tankSize/2
		

#改变方向的时候调整位置 设置成16px的倍数
func turnDirection():
#	position.y=round((position.y)/16)*16
#	position.x=round((position.x)/16)*16
	if dir==Dir.LEFT||dir==Dir.RIGHT:
		position.y=round((position.y)/16)*16
	else:
		position.x=round((position.x)/16)*16
		
		
func animation(dir,vec):
	if dir==Dir.UP:
		ani.flip_v=false
		ani.flip_h=false
		ani.rotation_degrees=0
	elif dir==Dir.DOWN:
		ani.flip_v=true
		ani.flip_h=false
		ani.rotation_degrees=0
	elif dir==Dir.LEFT:
		ani.flip_v=false
		ani.flip_h=true
		ani.rotation_degrees=-90
	elif dir==Dir.RIGHT:	
		ani.flip_v=false
		ani.flip_h=false
		ani.rotation_degrees=90

			
	if vec!=Vector2.ZERO:	
		ani.play("small_run")
	else:
		ani.play("small")
			
#发射子弹
func fire():
	if canShoot:
		var del=[]
		for i in bullets: #清理无效对象
			if not is_instance_valid(i):
				del.append(i)
		for i in del:
			bullets.remove(bullets.find(i))	
		if bullets.size()>=bulletMax:
			return
		canShoot=false
		shootTimer.start()
		var temp=bullet.instance()
		temp.position=position
		temp.dir=dir
		temp.ownId=get_instance_id()
		bullets.append(temp)
		Game.addObj(temp)


func _on_shootTimer_timeout():
	canShoot=true
