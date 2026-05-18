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
var lockDirFrame=4 #锁定方向的帧数
var lockDirTimer=4
var isTrapped=false  #是否被困住 如果上下左方向不能移动就是被困住
var trappedDir=[]
var trappedCount=0 #无法移动的方向

func _ready() -> void:
	shapeQuery.collide_with_areas=true
	shapeQuery.collision_mask=1+2
	shapeQuery.exclude=[get_rid()]
	shapeQuery.shape=shape.shape
	trappedDir.append_array([Vector2(0,-1),Vector2(1,0),Vector2(0,1),Vector2(-1,0)])
	
	

func _physics_process(_delta: float) -> void:
	var dir=FlowField.getFlowDir(global_position)
	bestDir=Vector2.ZERO
	isTrapped=false
	trappedCount=0
	var space_state = get_world_2d().direct_space_state
	#寻找合适的方向
	#var aviodDir=[]
	#var idx=dirs.find(dir)
	#aviodDir.push_front(dir)
	#for i in range(1,4): #顺时针
		#aviodDir.append(dirs[wrapi(idx+i,0,8)])
	#for i in range(1,4): #逆时针
		#aviodDir.append(dirs[wrapi(idx-i,0,8)])
	#aviodDir.append(dir*-1)	
	
	##如果7个方向都被阻挡 就试下反方向 没有方向就停止
	#for i in aviodDir:
		#shapeQuery.transform=Transform2D(global_rotation,global_position+
												#i.normalized()*speed*_delta)
		#var r=space_state.intersect_shape(shapeQuery,4)
		#if r.size()==0:
			#bestDir=i
			#break
			
	#先判断流场方向是否可以行走  如果不行就判断四正交主方向是否可以行走
	shapeQuery.transform=Transform2D(global_rotation,global_position+
												dir.normalized()*speed*_delta)
	var result=space_state.intersect_shape(shapeQuery,4)
	if result.size()==0:
		bestDir=dir
	else:
		for i in dir4Ortho:
			shapeQuery.transform=Transform2D(global_rotation,global_position+
												i.normalized()*speed*_delta)
			var r=space_state.intersect_shape(shapeQuery,4)
			if r.size()==0:
				bestDir=i
				break
	currDir=bestDir
	
	##获取附近的敌人，判断是不是主要方向被堵住了
	#var e=radar.get_overlapping_bodies()
	##print(aviodDir)
	#for i in aviodDir:
		#var checkPos=Vector2(floori(global_position.x/FlowField.cellSize.x),
			#floori(global_position.y/FlowField.cellSize.y))	+i
		#var blocked=false
		#if dir4Ortho.has(i):
			#for z in e:
				#if z==self:
					#continue
				#var grid=Vector2(floori(z.global_position.x/FlowField.cellSize.x),
				#floori(z.global_position.y/FlowField.cellSize.y))	
				#if grid.is_equal_approx(checkPos):
					#blocked=true
		#else: #斜方向
			#var tempDir=diagDepend[i]
			#for t in tempDir:
				#var tempDirPos=Vector2(floori(global_position.x/FlowField.cellSize.x),
					#floori(global_position.y/FlowField.cellSize.y))	+t
				#for z in e:
					#if z==self:
						#continue
					#var grid=Vector2(floori(z.global_position.x/FlowField.cellSize.x),
						#floori(z.global_position.y/FlowField.cellSize.y))	
					#if grid.is_equal_approx(tempDirPos):
						#blocked=true	
						#break	
			#for z in e:
				#if z==self:
					#continue
				#var grid=Vector2(floori(z.global_position.x/FlowField.cellSize.x),
				#floori(z.global_position.y/FlowField.cellSize.y))	
				#if grid.is_equal_approx(checkPos):
					#blocked=true
			#
			#
		#if !blocked:
			#bestDir=i
			#break	

	#for i in trappedDir:
		#var checkPos=global_position +i*FlowField.cellSize.x
		#for z in e:
			#if z==self:
				#continue
			#if checkPos.distance_to(z.global_position)<FlowField.cellSize.x:
				#trappedCount+=1	

		
	
	#限制当前方向移动几帧 然后才切换方向 防止频繁切换方向出现抖动
	if lockDirTimer<lockDirFrame:
		lockDirTimer+=1
	else:
		if currDir!=bestDir:
			lockDirTimer=0
		currDir=bestDir	
	
	#if trappedCount>=trappedDir.size(): #被困住就不动
		#currDir=Vector2.ZERO
	
	if global_position.distance_to(FlowField.target*FlowField.cellSize+FlowField.cellSize/2)<FlowField.cellSize.x:
		
		pass
	else:
		velocity =currDir.normalized()*speed
		move_and_collide(velocity*_delta)


func _draw() -> void:
	
	draw_rect(Rect2(Vector2.ZERO-size/2,size),Color.BLACK)
