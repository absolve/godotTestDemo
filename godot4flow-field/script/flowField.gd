extends Node

# 地图尺寸（格子数），32列 x 24行
var mapSize: Vector2 = Vector2(32, 24)
# 每个格子的像素大小，32x32像素
var cellSize: Vector2 = Vector2(32, 32)

# 距离场：记录每个格子到最近目标点的距离
# key格式为"x-y"，value为距离值
var distanceField: Dictionary = {}
# 流场：记录每个格子指向最近目标的方向向量
# key格式为"x-y"，value为方向向量（8方向之一）
var flowField: Dictionary = {}
# 障碍物集合：记录所有障碍物位置
# key格式为"x-y"，value为障碍物格子坐标
var obstacle: Dictionary = {}

# 是否显示计算动画（调试用）
var showAni = false
# 当前目标点列表（支持多目标）
var target: Array[Vector2] = []

# 计算流场和距离场
# 参数 _target 为可选的新增目标点，不传则使用已有target列表
func computeFields(_target: Vector2 = Vector2.INF):
	if _target != Vector2.INF:
		target.append(_target)
	
	# 第一步：初始化距离场，将所有格子距离设为无穷大
	for x in range(mapSize.x):
		for y in range(mapSize.y):
			distanceField["%s-%s" % [x, y]] = INF
	
	# 定义8个搜索方向（上下左右+四个对角线）
	var dirs = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1),
		Vector2(-1, -1), Vector2(-1, 1), Vector2(1, -1), Vector2(1, 1)]
	
	# 初始化BFS队列，将所有目标点加入队列
	var t: Array[Vector2] = []
	t.append_array(target)
	
	# 将目标点自身的距离设为0
	for i in target:
		distanceField["%s-%s" % [int(i.x), int(i.y)]] = 0
	
	# 第二步：BFS广度优先搜索计算距离场
	while t.size() > 0:
		# 取出队列头部的格子
		var p = t.pop_front()
		
		# 遍历8个方向的邻居格子
		for i in dirs:
			var pos: Vector2 = p + i
			
			# 边界检查：超出地图范围则跳过
			if pos.x < 0 || pos.y < 0 || pos.x >= mapSize.x || pos.y >= mapSize.y:
				continue
			
			# 障碍物检查：如果是障碍物则跳过
			if obstacle.has("%s-%s" % [int(pos.x), int(pos.y)]):
				continue
			
			# 如果该格子尚未计算距离（仍为INF）
			if distanceField["%s-%s" % [int(pos.x), int(pos.y)]] == INF:
				# 设置距离为父格子距离+1
				distanceField["%s-%s" % [int(pos.x), int(pos.y)]] = distanceField["%s-%s" % [int(p.x), int(p.y)]] + 1
				
				# 对角线移动额外加0.5（对角线距离更远）
				if i.x != 0 || i.y != 0:
					distanceField["%s-%s" % [int(pos.x), int(pos.y)]] += 0.5
				
				# 将该格子加入队列继续扩展
				t.append(pos)
		
		# 如果开启了动画显示，则每帧只处理一个格子，便于观察计算过程
		if showAni:
			await get_tree().process_frame
			
	# 第三步：根据距离场计算流场方向
	for x in range(mapSize.x):
		for y in range(mapSize.y):
			var mindistance = INF # 记录最小距离
			var bestDir = Vector2.ZERO # 记录最优方向
			var pos = Vector2(x, y)
			
			# 遍历8个方向，找到距离最近的邻居
			for i in dirs:
				var n = pos + i
				
				# 边界检查
				if n.x < 0 || n.y < 0 || n.x >= mapSize.x || n.y >= mapSize.y:
					continue
				
				# 障碍物检查（当前格子是否是障碍物）
				if obstacle.has("%s-%s" % [int(pos.x), int(pos.y)]):
					continue
				
				# 如果邻居格子的距离更小，则更新最小距离和最优方向
				if distanceField["%s-%s" % [int(n.x), int(n.y)]] < mindistance:
					mindistance = distanceField["%s-%s" % [int(n.x), int(n.y)]]
					bestDir = i
			
			# 将最优方向存入流场
			flowField["%s-%s" % [int(pos.x), int(pos.y)]] = bestDir
		
		# 动画显示支持
		if showAni:
			await get_tree().process_frame
			
# 根据世界坐标获取流场方向
# 参数 pos 为世界像素坐标
# 返回该位置所在格子的流场方向向量
func getFlowDir(pos: Vector2):
	# 将像素坐标转换为格子坐标
	var x = floori(pos.x / cellSize.x)
	var y = floori(pos.y / cellSize.y)
	
	# 如果该格子存在流场数据则返回方向，否则返回零向量
	if flowField.has("%s-%s" % [x, y]):
		return flowField["%s-%s" % [x, y]]
	else:
		return Vector2.ZERO

# 添加或移除障碍物
# 参数 pos 为格子坐标（不是像素坐标）
func addObstacle(pos: Vector2):
	# 如果障碍物已存在则移除，否则添加
	if obstacle.has("%s-%s" % [int(pos.x), int(pos.y)]):
		obstacle.erase("%s-%s" % [int(pos.x), int(pos.y)])
	else:
		obstacle["%s-%s" % [int(pos.x), int(pos.y)]] = pos
	
	# 障碍物变化后重新计算流场
	computeFields()
	
# 清空所有目标点并重新计算流场
func clearTargrt():
	target.clear()
	computeFields()