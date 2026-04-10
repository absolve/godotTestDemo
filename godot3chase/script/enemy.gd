# 敌人AI脚本
# 实现敌人的追逐行为和随机移动
extends KinematicBody2D

# 变量定义
var velocity=Vector2.ZERO	# 移动速度
var speed=130  # 移动速度值
var rayLength=80  # 射线长度
var rayCount=12  # 射线数量
var currentRayDir=null  # 当前移动方向
var rayDir=[]  # 所有方向的射线
var target=null	# 目标玩家
var startMove=false  # 是否开始移动
var moveTimer=0 # 移动定时器
var moveTime=300 # 移动时间
var debug=true  # 是否开启调试模式
var angularVel=5   # 旋转速度
var barrelAngVel=8  # 炮管旋转速度
var distance=100 # 停止距离

# 节点引用
onready var barrel=$barrel  # 炮管节点
onready var ani=$ani  # 动画节点

# 射线方向类
class RayDirections:
	var rayLength=0  # 射线长度
	var dir=Vector2.ZERO  # 射线方向
	var canMove=false  # 是否可以移动
	
	# 初始化函数
	# 参数: length - 射线长度, dir - 射线方向
	func _init(length : float, dir : Vector2):
		self.rayLength=length
		self.dir=dir

# 节点就绪时调用
func _ready():
	randomize()  # 初始化随机数
	# 创建射线方向
	for i in range(0,rayCount):
		var ray=RayDirections.new(rayLength,Vector2.RIGHT.rotated(i * PI * 2 / rayCount))
		rayDir.append(ray)

# 物理处理函数
func _physics_process(delta):
	if target:  # 如果有目标（玩家）
		# 获取空间状态
		var space_state = get_world_2d().direct_space_state
		# 检测每个方向是否可以移动
		for i in rayDir:
			var result=space_state.intersect_ray(global_position,global_position+i.dir*i.rayLength,[self],collision_mask)
			if result:
				i.canMove=false
			else:
				i.canMove=!test_move(self.global_transform,i.dir*speed*delta)
		
		# 计算目标方向
		var targetDir=target.global_position-global_position
		var angle=round(rad2deg((target.global_position - global_position).angle()))
		
		# 分类射线方向
		var raySameSide=[]  # 同侧射线
		var rayOtherSide=[]  # 对侧射线
		for i in rayDir:
			if i.canMove and i.dir.dot(currentRayDir.dir)>0:
				raySameSide.append(i)
			elif i.canMove:
				rayOtherSide.append(i)
		
		# 选择移动方向
		if currentRayDir.canMove:  # 如果当前方向可以移动
			# 寻找最接近目标的方向
			for i in  raySameSide:
				if targetDir.dot(i.dir)>=targetDir.dot(currentRayDir.dir):
					currentRayDir=i
		else:  # 如果当前方向不可移动
			var newDir=currentRayDir
			if !raySameSide.empty():  # 选择同侧可移动方向
				newDir=raySameSide[0]
				for i in  raySameSide:
					if i.dir.dot(currentRayDir.dir)>newDir.dir.dot(currentRayDir.dir):
						newDir=i
			elif !rayOtherSide.empty():# 选择对侧最接近目标的方向
				newDir=rayOtherSide[0]
				for i in rayOtherSide:
					if i.dir.dot(targetDir)>newDir.dir.dot(targetDir):
						newDir=i
			currentRayDir=newDir	

		# 处理角度计算
		if angle<0:
			angle=360-abs(angle)
		if 	abs(angle-ani.rotation_degrees)>180:
			if angle<ani.rotation_degrees:
				angle+=360
			else:
				angle-=360
		
		# 旋转炮管
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
			
		# 设置移动速度
		velocity=currentRayDir.dir*speed
		# 如果距离目标太近，停止移动
		if global_position.distance_to(target.global_position)<distance:
			velocity=Vector2.ZERO	
	else:  # 如果没有目标
		velocity=Vector2.ZERO
		if startMove:  # 如果正在移动
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
			# 检测移动方向
			var space_state = get_world_2d().direct_space_state
			for i in rayDir:
				var result=space_state.intersect_ray(global_position,global_position+i.dir*i.rayLength,[self],collision_mask)
				if result:
					i.canMove=false
				else:
					i.canMove=!test_move(self.global_transform,i.dir*speed*delta)
			# 如果当前方向可以移动
			if currentRayDir.canMove:
				velocity=currentRayDir.dir*speed
			else:
				currentRayDir=rayDir[randi()%rayDir.size()]
		else:  # 如果没有移动
			moveTimer+=1
			if moveTimer>moveTime:
				moveTimer=0
				moveTime=randi()%300+200
				var p=randi()%10
				if p>6:
					currentRayDir=rayDir[randi()%rayDir.size()]
					startMove=true
	
	# 移动角色
	move_and_collide(velocity*delta)	
	# 处理动画
	animation(delta)
	# 更新绘制
	update()

# 动画处理函数
# 参数: delta - 时间增量
func animation(delta):
	if velocity!=Vector2.ZERO:  # 如果有速度
		var angle=round(rad2deg(velocity.angle()))
		if angle<0:
			angle=360-abs(angle)
		if 	abs(angle-ani.rotation_degrees)>180:
			if angle<ani.rotation_degrees:
				angle+=360
			else:
				angle-=360
			
		# 旋转动画节点
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
	else:  # 如果没有速度，停止动画
		ani.stop()

# 被击中时的处理函数
# 参数: pos - 击中位置
func hit(pos:Vector2=Vector2.ZERO):
	target=Game.getPlayer()  # 设置目标为玩家
	var sameSide=[]
	# 根据击中位置选择同侧方向
	if position.x>pos.x:
		for i in rayDir:
			if i.dir.dot(Vector2.LEFT)>0:
				sameSide.append(i)
	else:
		for i in rayDir:
			if i.dir.dot(Vector2.RIGHT)>0:
				sameSide.append(i)
	# 随机选择一个同侧方向
	currentRayDir=sameSide[randi()%sameSide.size()]	

# 绘制调试信息
func _draw():
	if !debug:
		return
	# 绘制目标方向线
	if target:
		draw_line(Vector2(), (target.position-position ) , Color(0, 1, 0))
	
	# 绘制射线
	for i in rayDir:
		draw_line(Vector2.ZERO, (i.dir*i.rayLength) , Color(1.0, .329, .298))

# 检测到玩家进入区域时调用
func _on_Area2D_body_entered(body):
	target=body  # 设置目标为玩家
	var sameSide=[]
	# 根据玩家位置选择同侧方向
	if position.x>target.position.x:
		for i in rayDir:
			if i.dir.dot(Vector2.LEFT)>0:
				sameSide.append(i)
	else:
		for i in rayDir:
			if i.dir.dot(Vector2.RIGHT)>0:
				sameSide.append(i)
	# 随机选择一个同侧方向
	currentRayDir=sameSide[randi()%sameSide.size()]	

# 玩家离开区域时调用
func _on_Area2D_body_exited(body):
	target=null  # 清除目标
	# 判断是否继续移动
	var p=randi()%10
	if p>5:
		startMove=true
		moveTime=randi()%300+100
		currentRayDir=rayDir[randi()%rayDir.size()]
	else:
		startMove=false	
