extends Node

var mapSize:Vector2=Vector2(32,24)
var cellSize:Vector2=Vector2(32,32)

#目标点距离   key 为x-y  value为距离
var distanceField:Dictionary={}
#流场 指向最近目标的方向向量 key 为x-y value为方向
var flowField:Dictionary={}
#障碍物 key 为x-y value为方向
var obstacle:Dictionary={}

var showAni=false  #显示计算动画
var target=null

#计算流场
func computeFields(_target:Vector2):
	target=_target
	#初始化每个格子的距离
	for x in range(mapSize.x):
		for y in range(mapSize.y):
			distanceField["%s-%s"%[x,y]]=INF
	# 8方向搜索
	var dirs = [Vector2(-1,0),Vector2(1,0),Vector2(0,-1),Vector2(0,1),
		Vector2(-1,-1),Vector2(-1,1),Vector2(1,-1),Vector2(1,1)]
	var t:Array[Vector2] =[]
	t.append(_target)
	distanceField["%s-%s"%[int(_target.x),int(_target.y)]]=0
	#flowField["%s-%s"%[int(_target.x),int(_target.y)]]=null
	while t.size()>0:
		var p=t.pop_front()
		for i in dirs:  #获取邻居格子
			var pos:Vector2=p+i
			if pos.x<0||pos.y<0||pos.x>=mapSize.x||pos.y>=mapSize.y:
				continue
			if obstacle.has("%s-%s"%[int(pos.x),int(pos.y)]):
				continue
			if distanceField["%s-%s"%[int(pos.x),int(pos.y)]]==INF:
				distanceField["%s-%s"%[int(pos.x),int(pos.y)]]=distanceField["%s-%s"%[int(p.x),int(p.y)]]+1
				t.append(pos)
		if showAni:
			await get_tree().process_frame
			
	#计算流场方向
	for x in range(mapSize.x):
		for y in range(mapSize.y):
			var mindistance=INF
			var bestDir=Vector2.ZERO
			var pos=Vector2(x,y)
			for i in dirs:
				var n=pos+i
				if n.x<0||n.y<0||n.x>=mapSize.x||n.y>=mapSize.y:
					continue
				if obstacle.has("%s-%s"%[int(pos.x),int(pos.y)]):
					continue	
				if distanceField["%s-%s"%[int(n.x),int(n.y)]]<mindistance:
					mindistance=distanceField["%s-%s"%[int(n.x),int(n.y)]]
					bestDir=i
			flowField["%s-%s"%[int(pos.x),int(pos.y)]]=bestDir
		if showAni:
			await get_tree().process_frame
			
#查找流场位置方向		
func getFlowDir(pos:Vector2):
	var x=floori(pos.x/cellSize.x)
	var y=floori(pos.y/cellSize.y)
	if flowField.has("%s-%s"%[x,y]):
		return flowField["%s-%s"%[x,y]]
	else:
		return Vector2.ZERO

#添加障碍物  坐标为格子的位置
func addObstacle(pos:Vector2):
	if obstacle.has("%s-%s"%[int(pos.x),int(pos.y)]):
		obstacle.erase("%s-%s"%[int(pos.x),int(pos.y)])
	else:
		obstacle["%s-%s"%[int(pos.x),int(pos.y)]]=pos	
	if target!=null:
		computeFields(target)
		
