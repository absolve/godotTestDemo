extends Node2D

@onready var camera = $Camera2D
@onready var slider = $CanvasLayer/Control/VSlider

var dragging = false
var minZoom = Vector2(0.5, 0.5)
var maxZoom = Vector2(2, 2)
var zoomSpeed = 0.1
var mouse_start_pos = Vector2.ZERO
var zoomToCursor=true
var zoomPosOffset =Vector2.ZERO
var events={}	#事件列表
var lastDragDistance=0 #上次拖动距离

func _ready():
	pass


func _unhandled_input(_event):
	if OS.get_name() == "Windows":  #桌面环境
		if Input.is_action_just_pressed("move"):
			mouse_start_pos = _event.position
			dragging = true
		elif Input.is_action_just_released("move"):
			dragging = false

	if dragging:
		camera.offset += (
			(mouse_start_pos - get_viewport().get_mouse_position()) * (1 / camera.zoom.x)
		)
		mouse_start_pos = _event.position

	if OS.get_name() == "Windows":
		if Input.is_action_just_pressed("zoomIn"):
			zoom(maxZoom)	
		if Input.is_action_just_pressed("zoomOut"):
			zoom(minZoom)
			
	
	if OS.get_name() == "Android":
		if _event is InputEventScreenTouch:
			if _event.is_pressed():
				events[_event.index]=_event
			else:
				events.erase(_event.index)
		if _event is InputEventScreenDrag:
			events[_event.index]=_event
			if events.size()==1:
				camera.offset+=_event.relative*-1
			elif events.size()==2:
				var dragDistance=abs(events[0].position.distance_to(events[1].position))
				if dragDistance<lastDragDistance:
					zoom(minZoom)
				else:
					zoom(maxZoom)
				lastDragDistance=dragDistance
		
		#在项目中设置启用平移和缩放才会生效		
		if _event is InputEventMagnifyGesture:
			print('InputEventMagnifyGesture')
			camera.zoom *= _event.factor
			camera.zoom = clamp(camera.zoom, minZoom, maxZoom)
		if _event is InputEventPanGesture:
			print('InputEventPanGesture')
			camera.offset += _event.delta
			
	

#缩放
func zoom(value):
	if zoomToCursor:
		if  OS.get_name() == "Windows":
			zoomPosOffset=get_local_mouse_position()
		if OS.get_name() == "Android":
			zoomPosOffset=get_local_mouse_position()

	camera.zoom = clamp(lerp(camera.zoom, value, zoomSpeed), minZoom, maxZoom)
	if zoomToCursor:
		if  OS.get_name() == "Windows":
			camera.offset+=zoomPosOffset-get_local_mouse_position()
		if OS.get_name() == "Android":
			camera.offset+=zoomPosOffset-get_local_mouse_position()

			
func _on_button_pressed() -> void:
	camera.zoom = Vector2(1, 1)
	camera.offset = Vector2.ZERO
	slider.value = 1


func _on_v_slider_value_changed(value):
	#camera.zoom = Vector2(value, value)
	zoom(Vector2(value, value))
