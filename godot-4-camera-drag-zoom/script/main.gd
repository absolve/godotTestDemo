# 相机控制脚本
# 实现相机的平移和缩放功能，支持桌面和移动平台
extends Node2D

# 节点引用
@onready var camera = $Camera2D  # 相机节点
@onready var slider = $CanvasLayer/Control/VSlider  # 缩放滑块

# 变量定义
var dragging = false  # 是否正在拖动
var minZoom = Vector2(0.5, 0.5)  # 最小缩放
var maxZoom = Vector2(2, 2)  # 最大缩放
var zoomSpeed = 0.1  # 缩放速度
var mouse_start_pos = Vector2.ZERO  # 鼠标起始位置
var zoomToCursor=true  # 是否以光标为中心缩放
var zoomPosOffset =Vector2.ZERO  # 缩放位置偏移
var events={} # 事件列表（用于移动平台）
var lastDragDistance=0 # 上次拖动距离

# 节点就绪时调用
func _ready():
	pass

# 处理未处理的输入事件
# 参数: _event - 输入事件
func _unhandled_input(_event):
	# 桌面环境处理
	if OS.get_name() == "Windows":  # 桌面环境
		if Input.is_action_just_pressed("move"):
			mouse_start_pos = _event.position
			dragging = true
		elif Input.is_action_just_released("move"):
			dragging = false

	# 处理拖动
	if dragging:
		camera.offset += (
			(mouse_start_pos - get_viewport().get_mouse_position()) * (1 / camera.zoom.x)
		)
		mouse_start_pos = _event.position

	# 桌面环境缩放处理
	if OS.get_name() == "Windows":
		if Input.is_action_just_pressed("zoomIn"):
			zoom(maxZoom) 
		if Input.is_action_just_pressed("zoomOut"):
			zoom(minZoom)
			
	# 移动平台处理
	if OS.get_name() == "Android":
		# 处理触摸事件
		if _event is InputEventScreenTouch:
			if _event.is_pressed():
				events[_event.index]=_event
			else:
				events.erase(_event.index)
		# 处理拖动事件
		if _event is InputEventScreenDrag:
			events[_event.index]=_event
			if events.size()==1:  # 单指拖动
				camera.offset+=_event.relative*-1
			elif events.size()==2:  # 双指缩放
				var dragDistance=abs(events[0].position.distance_to(events[1].position))
				if dragDistance<lastDragDistance:
					zoom(minZoom)
				else:
					zoom(maxZoom)
				lastDragDistance=dragDistance
		
		# 在项目中设置启用平移和缩放才会生效		
		if _event is InputEventMagnifyGesture:  # 放大缩小手势
			print('InputEventMagnifyGesture')
			camera.zoom *= _event.factor
			camera.zoom = clamp(camera.zoom, minZoom, maxZoom)
		if _event is InputEventPanGesture:  # 平移手势
			print('InputEventPanGesture')
			camera.offset += _event.delta
			

# 缩放函数
# 参数: value - 目标缩放值
func zoom(value):
	# 记录缩放前的鼠标位置
	if zoomToCursor:
		if  OS.get_name() == "Windows":
			zoomPosOffset=get_local_mouse_position()
		if OS.get_name() == "Android":
			zoomPosOffset=get_local_mouse_position()

	# 执行缩放
	camera.zoom = clamp(lerp(camera.zoom, value, zoomSpeed), minZoom, maxZoom)
	
	# 调整相机偏移，使缩放以光标为中心
	if zoomToCursor:
		if  OS.get_name() == "Windows":
			camera.offset+=zoomPosOffset-get_local_mouse_position()
		if OS.get_name() == "Android":
			camera.offset+=zoomPosOffset-get_local_mouse_position()

		
# 重置按钮点击事件
func _on_button_pressed() -> void:
	# 重置相机状态
	camera.zoom = Vector2(1, 1)
	camera.offset = Vector2.ZERO
	slider.value = 1

# 滑块值变化事件
# 参数: value - 滑块值
func _on_v_slider_value_changed(value):
	# 执行缩放
	zoom(Vector2(value, value))
