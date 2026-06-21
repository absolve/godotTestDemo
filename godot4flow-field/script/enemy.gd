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
	
# 四正交主方向
const dir4Ortho = [
	Vector2(0,-1),  # 上
	Vector2(0,1),   # 下
	Vector2(-1,0),  # 左
	Vector2(1,0)    # 右
]
#每个方向与主方向的夹角
var dir4OrthoDot={
	Vector2(0,-1):0,
	Vector2(1,1): 0,
	Vector2(-1,1):0,
	Vector2(-1,-1):0
}
	
class dirInfo:
	var dir:Vector2
	var dot:float
	var canMove:bool #是否可以移动
	var distance  #距离目标的距离
	func _init(_dir:Vector2):
		self.dir=_dir
	func _to_string():
		return "dir:%s distance:%s"%[dir,distance]
	
#4个正反向对应的对焦方向	
var diagDepend = {
	Vector2(1,-1): [Vector2(0,-1), Vector2(1,0)],   # 右上 依赖上、右
	Vector2(1,1):  [Vector2(0,1),  Vector2(1,0)],   # 右下 依赖下、右
	Vector2(-1,1): [Vector2(0,1),  Vector2(-1,0)],  # 左下 依赖下、左
	Vector2(-1,-1):[Vector2(0,-1), Vector2(-1,0)]  # 左上 依赖上、左
}

var shapeQuery=PhysicsShapeQueryParameters2D.new()
var bestDir:Vector2=Vector2.ZERO
var currDir:Vector2=Vector2.ZERO  #当前移动方向
var lockDirFrame=20 #锁定方向的帧数
var lockDirTimer=20
var isTrapped=false  #是否被困住 如果上下左方向不能移动就是被困住
var trappedDir=[]
var trappedCount=0 #无法移动的方向
var recent_positions: Array[Vector2i] = [] #走过的格子
var recentMaxPos=5
var nextGrid=null
var limitDistance=4+32 #当敌人周边的格子方向有敌人，判定阻挡的距离
var canMove=true  #当前当前方向可以移动
var tryDir=[]  #在当前格子尝试不同的方向
var state=Game.enemyState.move

func _ready() -> void:
	shapeQuery.collide_with_areas=true
	shapeQuery.collision_mask=1+2
	shapeQuery.exclude=[get_rid()]
	shapeQuery.shape=shape.shape
	trappedDir.append_array([Vector2(0,-1),Vector2(1,0),Vector2(0,1),Vector2(-1,0)])
	#print(floori(global_position.x/FlowField.cellSize.x),
									#floori(global_position.x/FlowField.cellSize.x))
	

func _physics_process(_delta: float) -> void:
	#var dir=FlowField.getFlowDir(global_position)  #获取流场提供的方向
	#bestDir=Vector2.ZERO
	#isTrapped=false
	#trappedCount=0
	#canMove=true
	#if FlowField.target.is_empty():
		#return
	#var space_state = get_world_2d().direct_space_state
		#
	##先判断流场方向是否可以行走  如果不行就判断四正交主方向是否可以行走
	#shapeQuery.transform=Transform2D(global_rotation,global_position+
												#dir.normalized()*speed*_delta)
	#var current_grid =Vector2i(floori(global_position.x/FlowField.cellSize.x)	
		#,floori(global_position.y/FlowField.cellSize.y))			
	#var nextg=current_grid+Vector2i(dir	)	#目标下一个格子
	#var body=radar.get_overlapping_bodies()
	#if body:
		#for i in body:
			#if i==self:
				#continue
			#var pos=Vector2i(floori(i.global_position.x/FlowField.cellSize.x)
				#,floori(i.global_position.y/FlowField.cellSize.y))
			#if 	nextg==pos:  #当前格子上有敌人距离比较近就判断为无法行走
				#if global_position.distance_squared_to(i.global_position)<=limitDistance*limitDistance:
					#canMove=false
					#break				
	#if recent_positions.has(nextg):			
		#canMove=false
	#var result=space_state.intersect_shape(shapeQuery,4)
	#if result.size()==0 &&canMove: #如果当前方向的格子敌人距离比较近就判断为无法前进  必须地图内范围
		#bestDir=dir
		##var current_grid =Vector2i(floori(global_position.x/FlowField.cellSize.x)
		##,floori(global_position.y/FlowField.cellSize.y))
		#if recent_positions.size()>0&& recent_positions[-1]==current_grid:
			#pass
		#else:
			#recent_positions.append(current_grid)
		#if 	recent_positions.size()>recentMaxPos:
			#recent_positions.pop_front()
		#nextGrid=null	
		##recent_positions.clear()
	#else:
		####在4个方向中分别计算出每个方向距离目标点的距离，优先选择距离最小的方向
		####选择的方向必须到达指定方向的下一个格子的位置时才可以继续选择方向，记录走过的格子避免反复回头
		####如果当前还没有到达新方向的位置就碰到的障碍，重新选择新方向，之前的方向作为记录，4个方向都不能离开
		####当前格子就判定被困住不在移动  等待一段时间后在重新寻找方向
		#var selectDir:Array[dirInfo]=[]
		##var current_grid =Vector2i(floori(global_position.x/FlowField.cellSize.x),
									##floori(global_position.y/FlowField.cellSize.y))
		#for i in dir4Ortho:
			#shapeQuery.transform=Transform2D(global_rotation,global_position+
												#i.normalized()*speed*_delta)
			#var next_grid =current_grid+Vector2i(i)
			#if next_grid.x<0||next_grid.y<0||next_grid.x>=FlowField.mapSize.x||next_grid.y>=FlowField.mapSize.y:
				#continue
			##如果距离太近就不判断为不能移动
			#if body:
				#var hasEnemy=false
				#for b in body:
					#if b==self:
						#continue
					#var pos=Vector2i(floori(b.global_position.x/FlowField.cellSize.x)
						#,floori(b.global_position.y/FlowField.cellSize.y))
					#if 	next_grid==pos:  #当前格子上有敌人距离比较近就判断为无法行走
						#if global_position.distance_squared_to(b.global_position)<=limitDistance*limitDistance:
							#hasEnemy=true
							#break		
				#if hasEnemy:
					#continue
			#var r=space_state.intersect_shape(shapeQuery,4)
			#var di=dirInfo.new(i)
			##di.dot=dir.dot(i)
			#di.distance=next_grid.distance_squared_to(FlowField.target[0])
			#if r.is_empty():	#可以移动的方向
				#di.canMove=true
				#selectDir.append(di)
				#
		##根据距离进行排序
		#selectDir.sort_custom(func(a, b): return a.distance < b.distance)
		##print(selectDir)
		#if nextGrid==null :
			##print(current_grid,' ',selectDir)
			#if !selectDir.is_empty():
				#bestDir=selectDir[0].dir
				#nextGrid=current_grid+Vector2i(currDir)
		#else:
			##如果当前方向可以继续行走到附近格子继续前进
			##如果不能就重新选择走到附近的格子
			#shapeQuery.transform=Transform2D(global_rotation,global_position+
												#currDir.normalized()*speed*_delta)
			#var r=space_state.intersect_shape(shapeQuery,4)
			#if r.is_empty():
				#bestDir=currDir
			#else :  #重新选择前进到附近的格子
				##记录之前的方向
				#if !tryDir.has(currDir):
					#tryDir.append(currDir)
				#for i in selectDir:
					#var next_grid=current_grid+Vector2i(i.dir)
					#if !currDir.is_equal_approx(i.dir) && !tryDir.has(i.dir):
						#bestDir=i.dir
						#nextGrid=next_grid
						#break
				#
						#
			##如果已经到了下个格子则重新选择新的格子			
			#if current_grid==nextGrid:
				#tryDir.clear()
				#for i in selectDir:
					#var next_grid=current_grid+Vector2i(i.dir)
					#if !recent_positions.has(next_grid): #排除之前的方向不往回走
						#bestDir=i.dir
						#nextGrid=next_grid
						#break
			#
		#if recent_positions.size()>0&& recent_positions[-1]==current_grid:
			#pass
		#else:
			#recent_positions.append(current_grid)
		#if 	recent_positions.size()>recentMaxPos:
			#recent_positions.pop_front()
	
	if state==Game.enemyState.move:
		currDir=selectFlowField()
	elif state==Game.enemyState.findDir:
		currDir=findDir()			
	#currDir=selectDir()	
	if global_position.distance_to(FlowField.target[0]*FlowField.cellSize+FlowField.cellSize/2)<FlowField.cellSize.x:
		
		pass
	else:
		velocity =currDir*speed
		move_and_collide(velocity*_delta)

#根据流场方向
func selectFlowField():
	var dir=FlowField.getFlowDir(global_position)  #获取流场提供的方向
	shapeCast.target_position=size*dir
	shapeCast.force_shapecast_update()
	if shapeCast.is_colliding():
		var newDir=dir
		var canMoveDir=[]
		for i in range(7):
			newDir=newDir.rotated(PI/4)
			shapeCast.target_position=size*newDir
			shapeCast.force_shapecast_update()
			if !shapeCast.is_colliding():
				var d=dirInfo.new(newDir)
				d.dot=newDir.dot(newDir)
				canMoveDir.append(d)
		canMoveDir.sort_custom(func(a, b): return a.dot >= b.dot)
		if canMoveDir.size()>0:
			bestDir=canMoveDir[0].dir
			state=Game.enemyState.findDir
		else:
			bestDir= Vector2.ZERO	
	else:
		bestDir=dir	
	return bestDir	

##根据当前方向前进，如果碰到障碍物改变方向，如果当前敌人附近8个方向没有障碍物就
##切换回流场寻路的方向	
func findDir():
	if currDir!=Vector2.ZERO:
		shapeCast.target_position=size*currDir
		shapeCast.force_shapecast_update()
		if !shapeCast.is_colliding():
			bestDir=currDir
		else:
			#根据当前的方向旋转45度 7次旋转一个不会碰撞的角度
			var newDir=currDir
			var canMoveDir=[]
			for i in range(7):
				newDir=newDir.rotated(PI/4)
				shapeCast.target_position=size*newDir
				shapeCast.force_shapecast_update()
				if !shapeCast.is_colliding():
					var d=dirInfo.new(newDir)
					d.dot=newDir.dot(newDir)
					canMoveDir.append(d)
			canMoveDir.sort_custom(func(a, b): return a.dot >= b.dot)
			if canMoveDir.size()>0:
				bestDir=canMoveDir[0].dir
			else:
				bestDir= Vector2.ZERO	
	#判断敌人周边8个方向的位置是不是没有障碍物，如果是就切换回流场寻路状态
	var num=0
	for i in dirs:
		shapeCast.target_position=size*i
		shapeCast.force_shapecast_update()
		if !shapeCast.is_colliding():
			num+=1
	if num>=8:
		state=Game.enemyState.move
		
	return bestDir	
			
#选择方向
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
				d.dot=newDir.dot(newDir)
				canMoveDir.append(d)
		canMoveDir.sort_custom(func(a, b): return a.dot >= b.dot)
		if canMoveDir.size()>0:
			bestDir=canMoveDir[0].dir
		else:
			return Vector2.ZERO	
	else:
		bestDir=dir
	return bestDir.normalized()

#形成包围的队伍	
func selectTeamDir():
	var dir=FlowField.getFlowDir(global_position)  #获取流场提供的方向
	
	pass

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO-size/2,size),Color.BLACK)
