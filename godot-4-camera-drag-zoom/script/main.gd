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

func _ready():
	pass


func _unhandled_input(_event):
	if OS.get_name() == "Windows":  #桌面环境
		if Input.is_action_just_pressed("move"):
			mouse_start_pos = _event.position
			dragging = true
		elif Input.is_action_just_released("move"):
			dragging = false

	if OS.get_name() == "Android":
		if _event is InputEventMagnifyGesture:
			camera.zoom *= _event.factor
			camera.zoom = clamp(camera.zoom, minZoom, maxZoom)
		elif _event is InputEventPanGesture:
			camera.offset += _event.delta
		get_canvas_transform().affine_inverse().basis_xform(_event.position)

	if dragging:
		camera.offset += (
			(mouse_start_pos - get_viewport().get_mouse_position()) * (1 / camera.zoom.x)
		)
		mouse_start_pos = _event.position

	if OS.get_name() == "Windows":
		if Input.is_action_just_pressed("zoomIn"):
			#print("zoomIn")
			#camera.zoom = clamp(lerp(camera.zoom, maxZoom, zoomSpeed), minZoom, maxZoom)
			zoom(maxZoom)
				
		if Input.is_action_just_pressed("zoomOut"):
			#print("zoomOut")
			#camera.zoom = clamp(lerp(camera.zoom, minZoom, zoomSpeed), minZoom, maxZoom)
			zoom(minZoom)

#缩放
func zoom(value):
	if zoomToCursor:
		zoomPosOffset=get_global_mouse_position()
	camera.zoom = clamp(lerp(camera.zoom, value, zoomSpeed), minZoom, maxZoom)
	if zoomToCursor:
		camera.offset+=zoomPosOffset-get_global_mouse_position()

func _on_button_pressed() -> void:
	camera.zoom = Vector2(1, 1)
	camera.offset = Vector2.ZERO
	slider.value = 1


func _on_v_slider_value_changed(value):
	#camera.zoom = Vector2(value, value)
	zoom(Vector2(value, value))
