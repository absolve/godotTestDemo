extends Node2D

# 节点引用
@onready var camera = $Camera2D
@onready var timer = $Timer

# 字体资源（用于绘制文本）
var font: FontFile
# 暖色（用于距离场近的格子）
var warm_color = Color(1.0, 0.6, 0.2)
# 冷色（用于距离场远的格子）
var cool_color = Color(0.2, 0.5, 1.0)
# 最大敌人生成数量
@export var maxCount = 2
# 当前生成的敌人数量
var count = 0
# 敌人场景预加载
var enemy = preload("res://scene/enemy.tscn")

# 节点就绪时初始化
func _ready() -> void:
	# 获取默认字体
	font = ThemeDB.fallback_font
	# 设置初始目标点（可以设置多个目标点）
	# FlowField.target=[Vector2(30,20),Vector2(30,10)]
	FlowField.target = [Vector2(30, 20)]
	# 计算初始流场
	FlowField.computeFields()
	# 启动定时器（用于定时生成敌人）
	timer.start()


# 每帧更新：触发重绘
func _process(_delta: float) -> void:
	queue_redraw()
				

# 输入事件处理
func _input(_event: InputEvent) -> void:
	# 左键点击：设置新目标点
	if Input.is_action_just_pressed("click"):
		# 将鼠标位置转换为网格坐标
		var x1 = floori(get_global_mouse_position().x / FlowField.cellSize.x)
		var y1 = floori(get_global_mouse_position().y / FlowField.cellSize.y)
		print(x1, y1)
		# 清空原有目标并设置新目标
		FlowField.target = []
		FlowField.computeFields(Vector2(x1, y1))
	
	# 右键点击：添加/移除障碍物
	if Input.is_action_just_pressed("rightClick"):
		# 将鼠标位置转换为网格坐标
		var x1 = floori(get_global_mouse_position().x / FlowField.cellSize.x)
		var y1 = floori(get_global_mouse_position().y / FlowField.cellSize.y)
		# 切换障碍物状态（存在则移除，不存在则添加）
		FlowField.addObstacle(Vector2(x1, y1))
		

# 绘制流场可视化
func _draw() -> void:
	# 第一步：绘制距离场（用颜色渐变表示距离）
	for x in range(FlowField.mapSize.x):
		for y in range(FlowField.mapSize.y):
			if FlowField.distanceField.has("%s-%s" % [x, y]):
				# 距离为1的格子用暖色高亮
				if FlowField.distanceField["%s-%s" % [x, y]] == 1:
					draw_rect(Rect2(Vector2(x * FlowField.cellSize.x, y * FlowField.cellSize.y), FlowField.cellSize), warm_color)
				else:
					# 根据距离值进行颜色插值（近暖远冷）
					var c = warm_color.lerp(cool_color, min(FlowField.mapSize.x, FlowField.distanceField["%s-%s" % [x, y]]) / FlowField.mapSize.x)
					draw_rect(Rect2(Vector2(x * FlowField.cellSize.x, y * FlowField.cellSize.y), FlowField.cellSize), c)
	
	# 第二步：绘制流场方向（用绿色箭头表示）
	for x in range(FlowField.mapSize.x):
		for y in range(FlowField.mapSize.y):
			if FlowField.flowField.has("%s-%s" % [x, y]):
				# 根据方向向量绘制不同方向的箭头
				if FlowField.flowField["%s-%s" % [x, y]].is_equal_approx(Vector2.LEFT):
					draw_line(Vector2(x * FlowField.cellSize.x + FlowField.cellSize.x, y * FlowField.cellSize.y + FlowField.cellSize.y / 2),
					Vector2(x * FlowField.cellSize.x, y * FlowField.cellSize.y + FlowField.cellSize.y / 2), Color.GREEN)
					draw_circle(Vector2(x * FlowField.cellSize.x, y * FlowField.cellSize.y + FlowField.cellSize.y / 2),
					FlowField.cellSize.x / 8, Color.YELLOW)
				elif FlowField.flowField["%s-%s" % [x, y]].is_equal_approx(Vector2.RIGHT):
					draw_line(Vector2(x * FlowField.cellSize.x, y * FlowField.cellSize.y + FlowField.cellSize.y / 2),
					Vector2(x * FlowField.cellSize.x + FlowField.cellSize.x, y * FlowField.cellSize.y + FlowField.cellSize.y / 2), Color.GREEN)
					draw_circle(Vector2(x * FlowField.cellSize.x + FlowField.cellSize.x, y * FlowField.cellSize.y + FlowField.cellSize.y / 2),
					FlowField.cellSize.x / 8, Color.YELLOW)
				elif FlowField.flowField["%s-%s" % [x, y]].is_equal_approx(Vector2.UP):
					draw_line(Vector2(x * FlowField.cellSize.x + FlowField.cellSize.x / 2, y * FlowField.cellSize.y + FlowField.cellSize.y),
					Vector2(x * FlowField.cellSize.x + FlowField.cellSize.x / 2, y * FlowField.cellSize.y), Color.GREEN)
					draw_circle(Vector2(x * FlowField.cellSize.x + FlowField.cellSize.x / 2, y * FlowField.cellSize.y),
					FlowField.cellSize.x / 8, Color.YELLOW)
				elif FlowField.flowField["%s-%s" % [x, y]].is_equal_approx(Vector2.DOWN):
					draw_line(Vector2(x * FlowField.cellSize.x + FlowField.cellSize.x / 2, y * FlowField.cellSize.y),
					Vector2(x * FlowField.cellSize.x + FlowField.cellSize.x / 2, y * FlowField.cellSize.y + FlowField.cellSize.y), Color.GREEN)
					draw_circle(Vector2(x * FlowField.cellSize.x + FlowField.cellSize.x / 2, y * FlowField.cellSize.y + FlowField.cellSize.y),
					FlowField.cellSize.x / 8, Color.YELLOW)
				elif FlowField.flowField["%s-%s" % [x, y]].is_equal_approx(Vector2(-1, -1)):
					draw_line(Vector2(x * FlowField.cellSize.x + FlowField.cellSize.x, y * FlowField.cellSize.y + FlowField.cellSize.y),
					Vector2(x * FlowField.cellSize.x, y * FlowField.cellSize.y), Color.GREEN)
					draw_circle(Vector2(x * FlowField.cellSize.x, y * FlowField.cellSize.y),
					FlowField.cellSize.x / 8, Color.YELLOW)
				elif FlowField.flowField["%s-%s" % [x, y]].is_equal_approx(Vector2(1, 1)):
					draw_line(Vector2(x * FlowField.cellSize.x, y * FlowField.cellSize.y),
					Vector2(x * FlowField.cellSize.x + FlowField.cellSize.x, y * FlowField.cellSize.y + FlowField.cellSize.y), Color.GREEN)
					draw_circle(Vector2(x * FlowField.cellSize.x + FlowField.cellSize.x, y * FlowField.cellSize.y + FlowField.cellSize.y),
					FlowField.cellSize.x / 8, Color.YELLOW)
				elif FlowField.flowField["%s-%s" % [x, y]].is_equal_approx(Vector2(1, -1)):
					draw_line(Vector2(x * FlowField.cellSize.x, y * FlowField.cellSize.y),
					Vector2(x * FlowField.cellSize.x + FlowField.cellSize.x, y * FlowField.cellSize.y + FlowField.cellSize.y), Color.GREEN)
					draw_circle(Vector2(x * FlowField.cellSize.x + FlowField.cellSize.x, y * FlowField.cellSize.y),
					FlowField.cellSize.x / 8, Color.YELLOW)
				elif FlowField.flowField["%s-%s" % [x, y]].is_equal_approx(Vector2(-1, 1)):
					draw_line(Vector2(x * FlowField.cellSize.x + FlowField.cellSize.x, y * FlowField.cellSize.y),
					Vector2(x * FlowField.cellSize.x, y * FlowField.cellSize.y + FlowField.cellSize.y), Color.GREEN)
					draw_circle(Vector2(x * FlowField.cellSize.x, y * FlowField.cellSize.y + FlowField.cellSize.y),
					FlowField.cellSize.x / 8, Color.YELLOW)
					
	# 第三步：绘制目标点（红色圆圈）
	if FlowField.target != null && !FlowField.target.is_empty():
		for i in FlowField.target:
			draw_circle(i * FlowField.cellSize.x + FlowField.cellSize / 2, FlowField.cellSize.x / 3, Color.RED)
		

	# 第四步：绘制网格线（白色）
	for i in range(FlowField.mapSize.x):
		draw_line(Vector2(i * FlowField.cellSize.x, 0), Vector2(i * FlowField.cellSize.x, FlowField.mapSize.y * FlowField.cellSize.y), Color.WHITE, 1)
	
	for i in range(FlowField.mapSize.y):
		draw_line(Vector2(0, i * FlowField.cellSize.y), Vector2(FlowField.mapSize.x * FlowField.cellSize.x, i * FlowField.cellSize.y), Color.WHITE, 1)

	# 第五步：绘制障碍物（红色矩形）
	for i in FlowField.obstacle.keys():
		draw_rect(Rect2(FlowField.obstacle[i] * FlowField.cellSize.x, FlowField.cellSize), Color.RED)
	
	# 第六步：绘制鼠标位置信息（调试用）
	var x1 = floor(get_local_mouse_position().x)
	var y1 = floor(get_local_mouse_position().y)
	# 显示像素坐标
	draw_string(font, get_local_mouse_position(), "%s-%s" % [x1, y1],
	HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	# 显示网格坐标
	draw_string(font, get_local_mouse_position() + Vector2(20, 20), "%s-%s" % [floori(x1 / FlowField.cellSize.x),
	 floori(y1 / FlowField.cellSize.y)],
	HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)


# 定时器回调：定时生成敌人
func _on_timer_timeout() -> void:
	count += 1
	if count <= maxCount:
		# 实例化敌人场景
		var e = enemy.instantiate()
		# 设置敌人初始位置（地图左上角）
		e.position = Vector2(FlowField.cellSize) / 2
		# 将敌人添加到场景中
		add_child(e)
		# 重新启动定时器
		timer.start()