extends CharacterBody2D

# 节点引用
@onready var shape = $shape
@onready var radar = $radar
@onready var shapeCast = $ShapeCast2D


# 敌人尺寸
var size: Vector2 = Vector2(32, 32)
# 移动速度
var speed = 100
# 8个移动方向（按顺时针排列：左上、上、右上、右、右下、下、左下、左）
var dirs = [Vector2(-1, -1),
	Vector2(0, -1),
	Vector2(1, -1),
	Vector2(1, 0),
	Vector2(1, 1),
	Vector2(0, 1),
	Vector2(-1, 1),
	Vector2(-1, 0)]
	
# 方向信息类：用于存储候选方向的评分信息
class dirInfo:
	var dir: Vector2 # 方向向量
	var dot: float # 与原方向的点积（用于排序，值越大越接近原方向）
	var canMove: bool # 是否可以移动
	var distance # 距离目标的距离
	func _init(_dir: Vector2):
		self.dir = _dir
	func _to_string():
		return "dir:%s distance:%s" % [dir, distance]
	
# 当前最优移动方向
var bestDir: Vector2 = Vector2.ZERO
# 当前实际移动方向
var currDir: Vector2 = Vector2.ZERO
# 当前状态（从Game节点获取状态枚举）
var state = Game.enemyState.move
# 上一次记录的网格位置（用于判断是否移动了足够距离）
var lastGrid: Vector2i = Vector2.ZERO
# 最少移动格子数：当流场方向被阻挡时，需要移动这么多格子后才尝试切换回流场方向
var minMoveGrid = 2


func _ready() -> void:
	pass

# 物理帧更新：处理敌人移动逻辑
func _physics_process(_delta: float) -> void:
	# 根据当前状态选择移动方向
	if state == Game.enemyState.move:
		currDir = selectFlowField()
	elif state == Game.enemyState.findDir:
		currDir = findDir()
	
	# 检查是否到达目标点附近
	if global_position.distance_squared_to(FlowField.target[0] * size.x + size / 2) <= size.x * size.x:
		pass
	else:
		# 设置速度并移动
		velocity = currDir * speed
		move_and_collide(velocity * _delta)
	

# 根据流场方向选择移动方向
# 当流场方向被阻挡时，会选择一个与原方向最接近的可通行方向
func selectFlowField():
	# 获取当前位置所在的网格坐标
	var current_grid = Vector2i(floori(global_position.x / FlowField.cellSize.x)
		, floori(global_position.y / FlowField.cellSize.y))
	
	# 从流场获取当前位置的推荐方向
	var dir = FlowField.getFlowDir(global_position)
	
	# 使用ShapeCast检测该方向是否会发生碰撞
	shapeCast.target_position = size * dir
	shapeCast.force_shapecast_update()
	
	# 如果检测到碰撞（流场方向被阻挡）
	if shapeCast.is_colliding():
		var newDir = dir
		var canMoveDir = [] # 存储所有可通行的候选方向
		var newGrid: Vector2 = Vector2.ZERO
		
		# 尝试将流场方向旋转7次（每次45度），找到可通行的方向
		for i in range(7):
			newDir = newDir.rotated(PI / 4)
			newGrid = Vector2(current_grid) + newDir
			
			# 边界检查
			if newGrid.x < 0 || newGrid.x > FlowField.mapSize.x - 1 || \
				newGrid.y < 0 || newGrid.y > FlowField.mapSize.y - 1:
					continue
			
			# 检测该方向是否可通行
			shapeCast.target_position = size / 2 * newDir
			shapeCast.force_shapecast_update()
			if !shapeCast.is_colliding():
				# 创建方向信息对象，记录与原方向的点积
				var d = dirInfo.new(newDir)
				d.dot = newDir.dot(dir)
				canMoveDir.append(d)
		
		# 按点积排序，选择与原流场方向最接近的可通行方向
		canMoveDir.sort_custom(func(a, b): return a.dot >= b.dot)
		
		if canMoveDir.size() > 0:
			bestDir = canMoveDir[0].dir
			state = Game.enemyState.findDir # 切换到自主寻路状态
		else:
			bestDir = Vector2.ZERO # 没有可通行方向
		
		# 记录当前网格位置
		lastGrid = Vector2i(floori(global_position.x / FlowField.cellSize.x)
		, floori(global_position.y / FlowField.cellSize.y))
		
	else:
		# 流场方向可通行，直接使用流场方向
		bestDir = dir
	return bestDir.normalized()

## 自主寻路模式：当流场方向被阻挡时使用
## 根据当前方向前进，如果碰到障碍物则改变方向
## 行走至少minMoveGrid个格子后，尝试判断流场方向是否已恢复可通行
func findDir():
	# 获取当前位置所在的网格坐标
	var current_grid = Vector2i(floori(global_position.x / FlowField.cellSize.x)
		, floori(global_position.y / FlowField.cellSize.y))
	var newGrid: Vector2 = Vector2.ZERO
	
	# 如果当前有移动方向
	if currDir != Vector2.ZERO:
		# 检测当前方向是否可通行
		shapeCast.target_position = size * currDir
		shapeCast.force_shapecast_update()
		newGrid = Vector2(current_grid) + currDir
		
		# 如果当前方向可通行且在边界内
		if !shapeCast.is_colliding() && newGrid.x >= 0 && newGrid.x <= FlowField.mapSize.x - 1 && \
				newGrid.y >= 0 && newGrid.y <= FlowField.mapSize.y - 1:
			bestDir = currDir
		else:
			# 当前方向被阻挡，旋转寻找新方向
			var newDir = currDir
			var canMoveDir = []
			
			for i in range(7):
				newDir = newDir.rotated(PI / 4)
				newGrid = Vector2(current_grid) + newDir
				
				# 边界检查
				if newGrid.x < 0 || newGrid.x > FlowField.mapSize.x - 1 || \
					newGrid.y < 0 || newGrid.y > FlowField.mapSize.y - 1:
						continue
				
				# 检测该方向是否可通行
				shapeCast.target_position = size / 2 * newDir
				shapeCast.force_shapecast_update()
				if !shapeCast.is_colliding():
					var d = dirInfo.new(newDir)
					d.dot = newDir.dot(currDir)
					canMoveDir.append(d)
			
			# 按点积排序，选择与原方向最接近的可通行方向
			canMoveDir.sort_custom(func(a, b): return a.dot >= b.dot)
			
			if canMoveDir.size() > 0:
				bestDir = canMoveDir[0].dir
			else:
				bestDir = Vector2.ZERO
			
			# 更新上次记录的网格位置
			lastGrid = current_grid
	else:
		# 没有当前方向，切换回流场寻路状态
		state = Game.enemyState.move
		
	# 检查是否移动了足够距离，如果是则尝试切换回流场方向
	if lastGrid.distance_squared_to(current_grid) > minMoveGrid * minMoveGrid:
		var dir = FlowField.getFlowDir(global_position)
		shapeCast.target_position = size / 2 * dir
		shapeCast.force_shapecast_update()
		
		# 如果流场方向现在可通行，则切换回流场寻路状态
		if !shapeCast.is_colliding():
			bestDir = dir
			state = Game.enemyState.move
	
	return bestDir.normalized()
			

# 旧版方向选择函数（已废弃，保留仅供参考）
# ALERT BUG: 存在逻辑缺陷
func selectDir():
	var dir = FlowField.getFlowDir(global_position)
	shapeCast.target_position = size * dir
	shapeCast.force_shapecast_update()
	if shapeCast.is_colliding():
		if currDir != Vector2.ZERO:
			shapeCast.target_position = size * currDir
			shapeCast.force_shapecast_update()
			if !shapeCast.is_colliding():
				return currDir
		
		var newDir = dir
		var canMoveDir = []
		for i in range(7):
			newDir = newDir.rotated(PI / 4)
			shapeCast.target_position = size * newDir
			shapeCast.force_shapecast_update()
			if !shapeCast.is_colliding():
				var d = dirInfo.new(newDir)
				d.dot = newDir.dot(dir)
				canMoveDir.append(d)
		canMoveDir.sort_custom(func(a, b): return a.dot >= b.dot)
		if canMoveDir.size() > 0:
			bestDir = canMoveDir[0].dir
		else:
			return Vector2.ZERO
	else:
		bestDir = dir
	return bestDir.normalized()

# 待实现：团队包围逻辑
# TODO 形成包围的队伍	
func selectTeamDir():
	var dir = FlowField.getFlowDir(global_position)
	pass

# 绘制敌人外观
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO - size / 2, size), Color.BLACK)