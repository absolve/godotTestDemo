extends Node2D

@onready var camera = $Camera2D
@onready var slider = $CanvasLayer/Control/VSlider

var dragging = false
var minZoom = Vector2(0.5, 0.5)
var maxZoom = Vector2(2, 2)
var zoomSpeed = 0.1
var mouse_start_pos = Vector2.ZERO


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
			#var zoom_change = _event.factor * zoomSpeed
			#camera.zoom+=Vector2(zoom_change,zoom_change)
			camera.zoom *= _event.factor
			camera.zoom = clamp(camera.zoom, minZoom, maxZoom)
		elif _event is InputEventPanGesture:
			camera.offset += _event.delta
		#elif _event is InputEventScreenTouch and _event.pressed:
		#dragging = true
		#mouse_start_pos = get_global_mouse_position()
		#elif _event is InputEventScreenTouch and not _event.pressed:
		#dragging = false

	if dragging:
		camera.offset += (
			(mouse_start_pos - get_viewport().get_mouse_position()) * (1 / camera.zoom.x)
		)
		mouse_start_pos = _event.position

	if OS.get_name() == "Windows":
		if Input.is_action_pressed("zoomIn"):
			#print("zoomIn")
			camera.zoom = clamp(lerp(camera.zoom, maxZoom, zoomSpeed), minZoom, maxZoom)

		if Input.is_action_pressed("zoomOut"):
			#print("zoomOut")
			camera.zoom = clamp(lerp(camera.zoom, minZoom, zoomSpeed), minZoom, maxZoom)


func _on_button_pressed() -> void:
	camera.zoom = Vector2(1, 1)
	camera.offset = Vector2.ZERO
	slider.value = 1


func _on_v_slider_value_changed(value):
	camera.zoom = Vector2(value, value)
