extends CharacterBody2D

@onready var shape=$shape
@onready var radar=$radar
@onready var shapeCast=$ShapeCast2D


var size:Vector2=Vector2(32,32)
var speed=100
var dirs=[ Vector2(-1,-1),
	Vector2(0,-1),
	Vector2(1,-1),
	Vector2(1,0),
	Vector2(1,1),
	Vector2(0,1),
	Vector2(-1,1),
	Vector2(-1,0)]
	
class dirInfo:
	var dir:Vector2
	var dot:float
	var canMove:bool #是否可以移动
	var distance  #距离目标的距离
	func _init(_dir:Vector2):
		self.dir=_dir
	func _to_string():
		return "dir:%s distance:%s"%[dir,distance]
	
var bestDir:Vector2=Vector2.ZERO
var currDir:Vector2=Vector2.ZERO  #当前移动方向
var state=Game.enemyState.move
var lastGrid:Vector2i=Vector2.ZERO  #上一次网格位置
var minMoveGrid=2 #最少移动格子位置 如果流场方向无法移动


func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	if state==Game.enemyState.move:
		currDir=selectFlowField()
	elif state==Game.enemyState.findDir:
		currDir=findDir()			
	#currDir=selectDir()	
	#var current_grid =Vector2i(floori(global_position.x/FlowField.cellSize.x)	
		#,floori(global_position.y/FlowField.cellSize.y))	
	if global_position.distance_squared_to(FlowField.target[0]*size.x+size/2)<=size.x*size.x:
		
		pass
	else:
		velocity =currDir*speed
		move_and_collide(velocity*_delta)
	

#根据流场方向
func selectFlowField():
	var current_grid =Vector2i(floori(global_position.x/FlowField.cellSize.x)	
		,floori(global_position.y/FlowField.cellSize.y))
	var dir=FlowField.getFlowDir(global_position)  #获取流场提供的方向
	shapeCast.target_position=size*dir
	shapeCast.force_shapecast_update()
	if shapeCast.is_colliding():
		var newDir=dir
		var canMoveDir=[]
		var newGrid:Vector2=Vector2.ZERO
		for i in range(7):
			newDir=newDir.rotated(PI/4)
			newGrid=Vector2(current_grid)+newDir
			if newGrid.x<0||newGrid.x>FlowField.mapSize.x-1||\
				newGrid.y<0||newGrid.y>FlowField.mapSize.y-1:
					continue
			shapeCast.target_position=size/2*newDir
			shapeCast.force_shapecast_update()
			if !shapeCast.is_colliding():
				var d=dirInfo.new(newDir)
				d.dot=newDir.dot(dir)
				canMoveDir.append(d)
		canMoveDir.sort_custom(func(a, b): return a.dot >= b.dot)
		if canMoveDir.size()>0:
			bestDir=canMoveDir[0].dir
			state=Game.enemyState.findDir
		else:
			bestDir= Vector2.ZERO	
		lastGrid =Vector2i(floori(global_position.x/FlowField.cellSize.x)	
		,floori(global_position.y/FlowField.cellSize.y))		
		#bestDir= Vector2.ZERO	
		#state=Game.enemyState.findDir
	else:
		bestDir=dir	
	return bestDir.normalized()	

##根据当前方向前进，如果碰到障碍物改变方向，如果当前敌人附近8个方向没有障碍物就
##切换回流场寻路的方向	
##行走至少一个格子后判断流场方向能不能行走
func findDir():
	var current_grid =Vector2i(floori(global_position.x/FlowField.cellSize.x)	
		,floori(global_position.y/FlowField.cellSize.y))
	var newGrid:Vector2=Vector2.ZERO
	if currDir!=Vector2.ZERO:
		shapeCast.target_position=size*currDir
		shapeCast.force_shapecast_update()
		newGrid=Vector2(current_grid)+currDir
		if !shapeCast.is_colliding() &&newGrid.x>=0&&newGrid.x<=FlowField.mapSize.x-1&&\
				newGrid.y>=0&&newGrid.y<=FlowField.mapSize.y-1:
			bestDir=currDir
		else:
			#根据当前的方向旋转45度 7次旋转一个不会碰撞的角度
			var newDir=currDir
			var canMoveDir=[]	
			for i in range(7):
				newDir=newDir.rotated(PI/4)
				newGrid=Vector2(current_grid)+newDir
				if newGrid.x<0||newGrid.x>FlowField.mapSize.x-1||\
					newGrid.y<0||newGrid.y>FlowField.mapSize.y-1:
						continue
				shapeCast.target_position=size/2*newDir
				shapeCast.force_shapecast_update()
				if !shapeCast.is_colliding():
					var d=dirInfo.new(newDir)
					d.dot=newDir.dot(currDir)
					canMoveDir.append(d)
			canMoveDir.sort_custom(func(a, b): return a.dot >= b.dot)
			if canMoveDir.size()>0:
				bestDir=canMoveDir[0].dir
			else:
				bestDir= Vector2.ZERO	
			lastGrid=current_grid  #记录当前位置
	else:
		state=Game.enemyState.move
		
	if lastGrid.distance_squared_to(current_grid)>minMoveGrid*minMoveGrid:
		var dir=FlowField.getFlowDir(global_position)  #获取流场提供的方向
		shapeCast.target_position=size/2*dir
		shapeCast.force_shapecast_update()
		if !shapeCast.is_colliding():
			bestDir=dir
			state=Game.enemyState.move
	return bestDir.normalized()	
			
			
# ALERT BUG 选择方向  
func selectDir():
	var dir=FlowField.getFlowDir(global_position)  #获取流场提供的方向
	shapeCast.target_position=size*dir
	shapeCast.force_shapecast_update()
	if shapeCast.is_colliding():
		#var safe_scale: float = shapeCast.get_closest_collision_safe_fraction()
		#print("即将碰撞 | 安全移动比例: ", safe_scale)
		#如果当前方向可以行走先用当前方向
		if currDir!=Vector2.ZERO:
			shapeCast.target_position=size*currDir
			shapeCast.force_shapecast_update()
			if !shapeCast.is_colliding():
				return currDir
		
		#根据当前的方向旋转45度 7次旋转一个不会碰撞的角度
		var newDir=dir
		var canMoveDir=[]
		for i in range(7):
			newDir=newDir.rotated(PI/4)
			shapeCast.target_position=size*newDir
			shapeCast.force_shapecast_update()
			if !shapeCast.is_colliding():
				var d=dirInfo.new(newDir)
				d.dot=newDir.dot(dir)
				canMoveDir.append(d)
		canMoveDir.sort_custom(func(a, b): return a.dot >= b.dot)
		if canMoveDir.size()>0:
			bestDir=canMoveDir[0].dir
		else:
			return Vector2.ZERO	
	else:
		bestDir=dir
	return bestDir.normalized()

# TODO 形成包围的队伍	
func selectTeamDir():
	var dir=FlowField.getFlowDir(global_position)  #获取流场提供的方向
	pass

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO-size/2,size),Color.BLACK)
