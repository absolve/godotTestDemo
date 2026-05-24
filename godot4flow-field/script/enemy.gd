extends CharacterBody2D

@onready var shape=$shape
@onready var radar=$radar

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
var nextGrid=null
var limitDistance=5+32 #当敌人周边的格子方向有敌人，判定阻挡的距离
var canMove=true  #当前当前方向可以移动

func _ready() -> void:
	shapeQuery.collide_with_areas=true
	shapeQuery.collision_mask=1+2
	shapeQuery.exclude=[get_rid()]
	shapeQuery.shape=shape.shape
	trappedDir.append_array([Vector2(0,-1),Vector2(1,0),Vector2(0,1),Vector2(-1,0)])
	print(floori(global_position.x/FlowField.cellSize.x),
									floori(global_position.x/FlowField.cellSize.x))
	

func _physics_process(_delta: float) -> void:
	var dir=FlowField.getFlowDir(global_position)
	bestDir=Vector2.ZERO
	isTrapped=false
	trappedCount=0
	canMove=true
	if FlowField.target.is_empty():
		return
	var space_state = get_world_2d().direct_space_state
		
	#先判断流场方向是否可以行走  如果不行就判断四正交主方向是否可以行走
	shapeQuery.transform=Transform2D(global_rotation,global_position+
												dir.normalized()*speed*_delta)
	var current_grid =Vector2i(floori(global_position.x/FlowField.cellSize.x)	
		,floori(global_position.y/FlowField.cellSize.y))			
	var nextg=current_grid+Vector2i(dir	)	#目标下一个格子
	var body=radar.get_overlapping_bodies()
	if body:
		for i in body:
			if i==self:
				continue
			var pos=Vector2i(floori(i.global_position.x/FlowField.cellSize.x)
				,floori(i.global_position.y/FlowField.cellSize.y))
			if 	nextg==pos:  #当前格子上有敌人距离比较近就判断为无法行走
				if global_position.distance_squared_to(i.global_position)<=limitDistance*limitDistance:
					canMove=false
					break				
	var result=space_state.intersect_shape(shapeQuery,4)
	if result.size()==0 &&canMove: #如果当前方向的格子敌人距离比较近就判断为无法前进  必须地图内范围
		bestDir=dir
		#var current_grid =Vector2i(floori(global_position.x/FlowField.cellSize.x)
		#,floori(global_position.y/FlowField.cellSize.y))
		if recent_positions.size()>0&& recent_positions[-1]==current_grid:
			pass
		else:
			recent_positions.append(current_grid)
		if 	recent_positions.size()>4:
			recent_positions.pop_front()
		nextGrid=null	
	else:
		var selectDir:Array[dirInfo]=[]
		#var current_grid =Vector2i(floori(global_position.x/FlowField.cellSize.x),
									#floori(global_position.y/FlowField.cellSize.y))
		for i in dir4Ortho:
			shapeQuery.transform=Transform2D(global_rotation,global_position+
												i.normalized()*speed*_delta)
			var next_grid =current_grid+Vector2i(i)
			if next_grid.x<0||next_grid.y<0||next_grid.x>=FlowField.mapSize.x||next_grid.y>=FlowField.mapSize.y:
				continue
			#如果距离太近就不判断为不能移动
			
			var r=space_state.intersect_shape(shapeQuery,4)
			var di=dirInfo.new(i)
			di.dot=dir.dot(i)
			di.distance=next_grid.distance_squared_to(FlowField.target[0])
			if r.is_empty():	#可以移动的方向
				di.canMove=true
				selectDir.append(di)
				
		#距离近的
		selectDir.sort_custom(func(a, b): return a.distance < b.distance)
		#print(selectDir)
		if nextGrid==null :
			#print(current_grid,' ',selectDir)
			if !selectDir.is_empty():
				bestDir=selectDir[0].dir
				nextGrid=current_grid+Vector2i(currDir)
		else:
			#如果当前方向可以继续行走到附近格子继续前进
			#如果不能就重新选择附近的格子
			shapeQuery.transform=Transform2D(global_rotation,global_position+
												currDir.normalized()*speed*_delta)
			var r=space_state.intersect_shape(shapeQuery,4)
			if r.is_empty():
				bestDir=currDir
			else :  #重新选择前进到附近的格子
				for i in selectDir:
					var next_grid=current_grid+Vector2i(i.dir)
					if !recent_positions.has(next_grid):
						bestDir=i.dir
						nextGrid=next_grid
						break
					
			if current_grid==nextGrid:
				for i in selectDir:
					var next_grid=current_grid+Vector2i(i.dir)
					if !recent_positions.has(next_grid):
						bestDir=i.dir
						nextGrid=next_grid
						break
			
		if recent_positions.size()>0&& recent_positions[-1]==current_grid:
			pass
		else:
			recent_positions.append(current_grid)
		if 	recent_positions.size()>4:
			recent_positions.pop_front()
			
	currDir=bestDir	
	if global_position.distance_to(FlowField.target[0]*FlowField.cellSize+FlowField.cellSize/2)<FlowField.cellSize.x:
		
		pass
	else:
		velocity =currDir.normalized()*speed
		move_and_collide(velocity*_delta)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO-size/2,size),Color.BLACK)
