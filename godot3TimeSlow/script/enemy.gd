extends KinematicBody2D


var velocity=Vector2.ZERO	#速度
var speed=130
var rayLength=80
var rayCount=12
var currentRayDir=null  #当前的方向
var rayDir=[]  #所有的方向射线
var target=null	#指定出现在范围内的玩家
var startMove=false  #开始移动
var moveTimer=0 #移动定时器
var moveTime=300 #移动时间
var debug=true
var angularVel=5   #旋转速度
var barrelAngVel=8
var distance=100 #超过距离

onready var barrel=$barrel
onready var ani=$ani

class RayDirections:
	var rayLength=0
	var dir=Vector2.ZERO
	var canMove=false
	
	func _init(length : float, dir : Vector2):
		self.rayLength=length
		self.dir=dir

func _ready():
	randomize()
	for i in range(0,rayCount):
		var ray=RayDirections.new(rayLength,Vector2.RIGHT.rotated(i * PI * 2 / rayCount))
		rayDir.append(ray)
	


func _physics_process(delta):
	if target:
		var space_state = get_world_2d().direct_space_state
		for i in rayDir:#判断每个方向是否发生碰撞
			var result=space_state.intersect_ray(global_position,global_position+i.dir*i.rayLength,[self],collision_mask)
			if result:
				i.canMove=false
			else:
				i.canMove=!test_move(self.global_transform,i.dir*speed*delta)
		var targetDir=target.global_position-global_position
		var angle=round(rad2deg((target.global_position - global_position).angle()))
		var raySameSide=[]
		var rayOtherSide=[]
		for i in rayDir:
			if i.canMove and i.dir.dot(currentRayDir.dir)>0:
				raySameSide.append(i)
			elif i.canMove:
				rayOtherSide.append(i)
		if currentRayDir.canMove:  #如果当前的方向可以移动，就寻找一个离目标最接近的方向
			for i in  raySameSide:
				if targetDir.dot(i.dir)>=targetDir.dot(currentRayDir.dir):
					currentRayDir=i
		else:
			var newDir=currentRayDir
			if !raySameSide.empty():  #选择一个可以移动的方向
				newDir=raySameSide[0]
				for i in  raySameSide:
					if i.dir.dot(currentRayDir.dir)>newDir.dir.dot(currentRayDir.dir):
						newDir=i
			elif !rayOtherSide.empty():#在反方向选择一个与目标接近的方向
				newDir=rayOtherSide[0]
				for i in rayOtherSide:
					if i.dir.dot(targetDir)>newDir.dir.dot(targetDir):
						newDir=i
			currentRayDir=newDir	
	
		if angle<0:
			angle=360-abs(angle)
		if 	abs(angle-ani.rotation_degrees)>180:#变化的幅度超过180 就把angle增加360或者较少360
			if angle<ani.rotation_degrees:
				angle+=360
			else:
				angle-=360
		if barrel.rotation_degrees!=angle:
			if barrel.rotation_degrees>angle:
				if barrel.rotation_degrees-barrelAngVel<angle:
					barrel.rotation_degrees=angle
				else:
					barrel.rotation_degrees-=barrelAngVel
			if barrel.rotation_degrees<angle:	
				if barrel.rotation_degrees+barrelAngVel>angle:
					barrel.rotation_degrees=angle
				else:
					barrel.rotation_degrees+=barrelAngVel
			
		velocity=currentRayDir.dir*speed
		if global_position.distance_to(target.global_position)<distance:
			velocity=Vector2.ZERO	
	else:
		velocity=Vector2.ZERO
		if startMove:
			moveTimer+=1
			if moveTimer>moveTime:
				var p=randi()%10
				moveTimer=0
				if p>=5:
					startMove=true
					moveTime=randi()%300+100
					currentRayDir=rayDir[randi()%rayDir.size()]
				else:
					startMove=false	
			var space_state = get_world_2d().direct_space_state
			for i in rayDir:
				var result=space_state.intersect_ray(global_position,global_position+i.dir*i.rayLength,[self],collision_mask)
				if result:
					i.canMove=false
				else:
					i.canMove=!test_move(self.global_transform,i.dir*speed*delta)
			if currentRayDir.canMove:
				velocity=currentRayDir.dir*speed
			else:
				currentRayDir=rayDir[randi()%rayDir.size()]
		else:
			moveTimer+=1
			if moveTimer>moveTime:
				moveTimer=0
				moveTime=randi()%300+200
				var p=randi()%10
				if p>6:
					currentRayDir=rayDir[randi()%rayDir.size()]
					startMove=true
	move_and_collide(velocity*delta)	
	animation(delta)
	update()

func animation(delta):
	if velocity!=Vector2.ZERO:
		var angle=round(rad2deg(velocity.angle()))
		if angle<0:
			angle=360-abs(angle)
		if 	abs(angle-ani.rotation_degrees)>180:#变化的幅度超过180 就把angle增加360或者减少360
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

func hit(pos:Vector2=Vector2.ZERO):
	target=Game.getPlayer()
	var sameSide=[]
	if position.x>pos.x:
		for i in rayDir:
			if i.dir.dot(Vector2.LEFT)>0:
				sameSide.append(i)
	else:
		for i in rayDir:
			if i.dir.dot(Vector2.RIGHT)>0:
				sameSide.append(i)
	currentRayDir=sameSide[randi()%sameSide.size()]	
	
func _draw():
	if !debug:
		return
	if target:
		draw_line(Vector2(), (target.position-position ) , Color(0, 1, 0))
	
	for i in rayDir:
		draw_line(Vector2.ZERO, (i.dir*i.rayLength) , Color(1.0, .329, .298))


func _on_Area2D_body_entered(body):
	target=body
	var sameSide=[]
	if position.x>target.position.x:
		for i in rayDir:
			if i.dir.dot(Vector2.LEFT)>0:
				sameSide.append(i)
	else:
		for i in rayDir:
			if i.dir.dot(Vector2.RIGHT)>0:
				sameSide.append(i)
	currentRayDir=sameSide[randi()%sameSide.size()]	



func _on_Area2D_body_exited(body):
	target=null
	#判断是否继续移动
	var p=randi()%10
	if p>5:
		startMove=true
		moveTime=randi()%300+100
		currentRayDir=rayDir[randi()%rayDir.size()]
	else:
		startMove=false	
