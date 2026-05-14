extends Node2D

@onready var camera=$Camera2D


var font: FontFile
var warm_color = Color(1.0, 0.6, 0.2) 
var cool_color = Color(0.2, 0.5, 1.0)

func _ready() -> void:
	font=ThemeDB.fallback_font
	FlowField.computeFields(Vector2(30,20))
	pass
		


func _process(_delta: float) -> void:
	queue_redraw()
				

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		var x1 = floori(get_global_mouse_position().x/ FlowField.cellSize.x)
		var y1 = floori(get_global_mouse_position().y/ FlowField.cellSize.y)
		print(x1,y1)
		FlowField.computeFields(Vector2(x1,y1))



func _draw() -> void:
	
	#绘制距离
	for x in range(FlowField.mapSize.x):
		for y in range(FlowField.mapSize.y):
			if FlowField.distanceField.has("%s-%s"%[x,y]):
				if FlowField.distanceField["%s-%s"%[x,y]]==1:
					draw_rect(Rect2(Vector2(x*FlowField.cellSize.x,y*FlowField.cellSize.y),FlowField.cellSize),warm_color)
				else:
					var c=warm_color.lerp(cool_color,min(FlowField.mapSize.x,FlowField.distanceField["%s-%s"%[x,y]])/FlowField.mapSize.x)
					draw_rect(Rect2(Vector2(x*FlowField.cellSize.x,y*FlowField.cellSize.y),FlowField.cellSize),c)
	
	for x in range(FlowField.mapSize.x):
		for y in range(FlowField.mapSize.y):
			if FlowField.flowField.has("%s-%s"%[x,y]):
				if FlowField.flowField["%s-%s"%[x,y]].is_equal_approx(Vector2.LEFT):
					draw_line(Vector2(x*FlowField.cellSize.x+FlowField.cellSize.x,y*FlowField.cellSize.y+FlowField.cellSize.y/2),
					Vector2(x*FlowField.cellSize.x,y*FlowField.cellSize.y+FlowField.cellSize.y/2),Color.GREEN)
					draw_circle(Vector2(x*FlowField.cellSize.x,y*FlowField.cellSize.y+FlowField.cellSize.y/2),
					FlowField.cellSize.x/8,Color.YELLOW)
				elif FlowField.flowField["%s-%s"%[x,y]].is_equal_approx(Vector2.RIGHT):
					draw_line(Vector2(x*FlowField.cellSize.x+FlowField.cellSize.x,y*FlowField.cellSize.y+FlowField.cellSize.y/2),
					Vector2(x*FlowField.cellSize.x,y*FlowField.cellSize.y+FlowField.cellSize.y/2),Color.GREEN)
					draw_circle(Vector2(x*FlowField.cellSize.x+FlowField.cellSize.x,y*FlowField.cellSize.y+FlowField.cellSize.y/2),
					FlowField.cellSize.x/8,Color.YELLOW)
				elif FlowField.flowField["%s-%s"%[x,y]].is_equal_approx(Vector2.UP):
					draw_line(Vector2(x*FlowField.cellSize.x+FlowField.cellSize.x/2,y*FlowField.cellSize.y),
					Vector2(x*FlowField.cellSize.x+FlowField.cellSize.x/2,y*FlowField.cellSize.y+FlowField.cellSize.y),Color.GREEN)
					draw_circle(Vector2(x*FlowField.cellSize.x+FlowField.cellSize.x/2,y*FlowField.cellSize.y),
					FlowField.cellSize.x/8,Color.YELLOW)
				elif FlowField.flowField["%s-%s"%[x,y]].is_equal_approx(Vector2.DOWN):	
					draw_line(Vector2(x*FlowField.cellSize.x+FlowField.cellSize.x/2,y*FlowField.cellSize.y),
					Vector2(x*FlowField.cellSize.x+FlowField.cellSize.x/2,y*FlowField.cellSize.y+FlowField.cellSize.y),Color.GREEN)
					draw_circle(Vector2(x*FlowField.cellSize.x+FlowField.cellSize.x/2,y*FlowField.cellSize.y+FlowField.cellSize.y),
					FlowField.cellSize.x/8,Color.YELLOW)
				elif FlowField.flowField["%s-%s"%[x,y]].is_equal_approx(Vector2(-1,-1)):	
					draw_line(Vector2(x*FlowField.cellSize.x,y*FlowField.cellSize.y),
					Vector2(x*FlowField.cellSize.x+FlowField.cellSize.x,y*FlowField.cellSize.y+FlowField.cellSize.y),Color.GREEN)
					draw_circle(Vector2(x*FlowField.cellSize.x,y*FlowField.cellSize.y),
					FlowField.cellSize.x/8,Color.YELLOW)
				elif FlowField.flowField["%s-%s"%[x,y]].is_equal_approx(Vector2(1,1)):	
					draw_line(Vector2(x*FlowField.cellSize.x,y*FlowField.cellSize.y),
					Vector2(x*FlowField.cellSize.x+FlowField.cellSize.x,y*FlowField.cellSize.y+FlowField.cellSize.y),Color.GREEN)
					draw_circle(Vector2(x*FlowField.cellSize.x+FlowField.cellSize.x,y*FlowField.cellSize.y+FlowField.cellSize.y),
					FlowField.cellSize.x/8,Color.YELLOW)
				elif FlowField.flowField["%s-%s"%[x,y]].is_equal_approx(Vector2(1,-1)):	
					draw_line(Vector2(x*FlowField.cellSize.x,y*FlowField.cellSize.y+FlowField.cellSize.y),
					Vector2(x*FlowField.cellSize.x+FlowField.cellSize.x,y*FlowField.cellSize.y),Color.GREEN)
					draw_circle(Vector2(x*FlowField.cellSize.x+FlowField.cellSize.x,y*FlowField.cellSize.y),
					FlowField.cellSize.x/8,Color.YELLOW)
				elif FlowField.flowField["%s-%s"%[x,y]].is_equal_approx(Vector2(-1,1)):		
					draw_line(Vector2(x*FlowField.cellSize.x,y*FlowField.cellSize.y+FlowField.cellSize.y),
					Vector2(x*FlowField.cellSize.x+FlowField.cellSize.x,y*FlowField.cellSize.y),Color.GREEN)
					draw_circle(Vector2(x*FlowField.cellSize.x,y*FlowField.cellSize.y+FlowField.cellSize.y),
					FlowField.cellSize.x/8,Color.YELLOW)
					
	if FlowField.target!=null:
		draw_circle(FlowField.target*FlowField.cellSize.x+FlowField.cellSize/2,FlowField.cellSize.x/3,Color.RED)
		
		
	for i in range(FlowField.mapSize.x):
		draw_line(Vector2(i*FlowField.cellSize.x,0),Vector2(i*FlowField.cellSize.x,FlowField.mapSize.y*FlowField.cellSize.y),Color.WHITE,1)
	
	for i in range(FlowField.mapSize.y):
		draw_line(Vector2(0,i*FlowField.cellSize.y),Vector2(FlowField.mapSize.x*FlowField.cellSize.x,i*FlowField.cellSize.y),Color.WHITE,1)	


	
	var x1 = floor(get_local_mouse_position().x)
	var y1 = floor(get_local_mouse_position().y)
	draw_string(font, get_local_mouse_position(), "%s-%s" % [x1, y1],
	HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	draw_string(font, get_local_mouse_position() + Vector2(20, 20), "%s-%s" % [floori(x1 / FlowField.cellSize.x),
	 floori(y1 / FlowField.cellSize.y)],
	HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
