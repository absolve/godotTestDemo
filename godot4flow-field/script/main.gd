extends Node2D

@onready var camera=$Camera2D

var mapSize:Vector2=Vector2(32,24)
var cellSize:Vector2=Vector2(32,32)

#目标点距离   key 为x-y  value为距离
var distanceField:Dictionary={}
#流场 指向最近目标的方向向量 key 为x-y value为方向
var flowField:Dictionary={}

var target=null
var font: FontFile
var warm_color = Color(1.0, 0.6, 0.2) 
var cool_color = Color(0.2, 0.5, 1.0)

func _ready() -> void:
	computeFields(Vector2(1,0))
	font=ThemeDB.fallback_font
	pass

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
	while t.size()>0:
		var p=t.pop_front()
		for i in dirs:  #获取邻居格子
			var pos:Vector2=p+i
			if pos.x<0||pos.y<0||pos.x>=mapSize.x||pos.y>=mapSize.y:
				continue
			if distanceField["%s-%s"%[int(pos.x),int(pos.y)]]==INF:
				distanceField["%s-%s"%[int(pos.x),int(pos.y)]]=distanceField["%s-%s"%[int(p.x),int(p.y)]]+1
				t.append(pos)
	
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
				if distanceField["%s-%s"%[int(n.x),int(n.y)]]<mindistance:
					mindistance=distanceField["%s-%s"%[int(n.x),int(n.y)]]
					bestDir=i
			flowField["%s-%s"%[int(pos.x),int(pos.y)]]=bestDir
	pass			


func _process(_delta: float) -> void:
	queue_redraw()
				

func _input(event: InputEvent) -> void:
	
	
	
	pass


func _draw() -> void:
	
	
	var x1 = floor(get_local_mouse_position().x)
	var y1 = floor(get_local_mouse_position().y)
	draw_string(font, get_local_mouse_position(), "%s-%s" % [x1, y1],
	HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	draw_string(font, get_local_mouse_position() + Vector2(20, 20), "%s-%s" % [floori(x1 / cellSize.x),
	 floori(y1 / cellSize.y)],
	HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	
	#绘制距离
	for x in range(mapSize.x):
		for y in range(mapSize.y):
			if distanceField.has("%s-%s"%[x,y]):
				if distanceField["%s-%s"%[x,y]]==1:
					draw_rect(Rect2(Vector2(x*cellSize.x,y*cellSize.y),cellSize),warm_color)
				else:
					var c=warm_color.lerp(cool_color,min(mapSize.x,distanceField["%s-%s"%[x,y]])/mapSize.x)
					draw_rect(Rect2(Vector2(x*cellSize.x,y*cellSize.y),cellSize),c)
				pass
	
	for x in range(mapSize.x):
		for y in range(mapSize.y):
			if flowField.has("%s-%s"%[x,y]):
				if flowField["%s-%s"%[x,y]].is_equal_approx(Vector2.LEFT):
					draw_line(Vector2(x*cellSize.x+cellSize.x,y*cellSize.y+cellSize.y/2),
					Vector2(x*cellSize.x,y*cellSize.y+cellSize.y/2),Color.GREEN)
					draw_circle(Vector2(x*cellSize.x,y*cellSize.y+cellSize.y/2),
					cellSize.x/8,Color.YELLOW)
				elif flowField["%s-%s"%[x,y]].is_equal_approx(Vector2.RIGHT):
					draw_line(Vector2(x*cellSize.x+cellSize.x,y*cellSize.y+cellSize.y/2),
					Vector2(x*cellSize.x,y*cellSize.y+cellSize.y/2),Color.GREEN)
					draw_circle(Vector2(x*cellSize.x+cellSize.x,y*cellSize.y+cellSize.y/2),
					cellSize.x/8,Color.YELLOW)
				elif flowField["%s-%s"%[x,y]].is_equal_approx(Vector2.UP):
					draw_line(Vector2(x*cellSize.x+cellSize.x/2,y*cellSize.y),
					Vector2(x*cellSize.x+cellSize.x/2,y*cellSize.y+cellSize.y),Color.GREEN)
					draw_circle(Vector2(x*cellSize.x+cellSize.x/2,y*cellSize.y),
					cellSize.x/8,Color.YELLOW)
				elif flowField["%s-%s"%[x,y]].is_equal_approx(Vector2.DOWN):	
					draw_line(Vector2(x*cellSize.x+cellSize.x/2,y*cellSize.y),
					Vector2(x*cellSize.x+cellSize.x/2,y*cellSize.y+cellSize.y),Color.GREEN)
					draw_circle(Vector2(x*cellSize.x+cellSize.x/2,y*cellSize.y+cellSize.y),
					cellSize.x/8,Color.YELLOW)
				elif flowField["%s-%s"%[x,y]].is_equal_approx(Vector2(-1,-1)):	
					draw_line(Vector2(x*cellSize.x,y*cellSize.y),
					Vector2(x*cellSize.x+cellSize.x,y*cellSize.y+cellSize.y),Color.GREEN)
					draw_circle(Vector2(x*cellSize.x,y*cellSize.y),
					cellSize.x/8,Color.YELLOW)
				elif flowField["%s-%s"%[x,y]].is_equal_approx(Vector2(1,1)):	
					draw_line(Vector2(x*cellSize.x,y*cellSize.y),
					Vector2(x*cellSize.x+cellSize.x,y*cellSize.y+cellSize.y),Color.GREEN)
					draw_circle(Vector2(x*cellSize.x+cellSize.x,y*cellSize.y+cellSize.y),
					cellSize.x/8,Color.YELLOW)
				elif flowField["%s-%s"%[x,y]].is_equal_approx(Vector2(1,-1)):	
					draw_line(Vector2(x*cellSize.x,y*cellSize.y+cellSize.y),
					Vector2(x*cellSize.x+cellSize.x,y*cellSize.y),Color.GREEN)
					draw_circle(Vector2(x*cellSize.x+cellSize.x,y*cellSize.y),
					cellSize.x/8,Color.YELLOW)
				elif flowField["%s-%s"%[x,y]].is_equal_approx(Vector2(-1,1)):		
					draw_line(Vector2(x*cellSize.x,y*cellSize.y+cellSize.y),
					Vector2(x*cellSize.x+cellSize.x,y*cellSize.y),Color.GREEN)
					draw_circle(Vector2(x*cellSize.x,y*cellSize.y+cellSize.y),
					cellSize.x/8,Color.YELLOW)
					
	if target!=null:
		draw_circle(target*cellSize.x+cellSize/2,cellSize.x/3,Color.RED)
		
		
	for i in range(mapSize.x):
		draw_line(Vector2(i*cellSize.x,0),Vector2(i*cellSize.x,mapSize.y*cellSize.y),Color.WHITE,1)
	
	for i in range(mapSize.y):
		draw_line(Vector2(0,i*cellSize.y),Vector2(mapSize.x*cellSize.x,i*cellSize.y),Color.WHITE,1)	
