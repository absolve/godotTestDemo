class_name DemoHud
extends CanvasLayer

## 演示 HUD —— demo 里所有「显示」都住在这一个 CanvasLayer 里。
##
## 它是 `scene/map.tscn` 里一个**存下来的节点**（scene/demo_hud.tscn 的实例），
## 不是运行时拼出来的 —— 编辑器里能直接看见，也能调位置和样式。
## 上一版是控制器 `add_child` 出来的，只能在运行时存在，等于没法调。
##
## 为什么单独一层：
##   · 「镜头怎么动」和「画什么」是两件事；混在一起的话，每调一次显示都要动相机那头；
##   · CanvasLayer 天生不参与 2D 世界变换，而且保证画在地图之上。这两点都不是
##     可有可无的：把 Label 挂相机身上，相机是 FIXED_TOP_LEFT，节点位置表示可视区
##     左上角，UI 会被相机变换拖着跑；挂父节点 + `top_level = true` 也没用 ——
##     top_level 是 Node3D 的属性，对 CanvasItem 不起作用，HUD 会直接不显示。
##
## 数据是单向的：控制器（script/demo_map.gd，挂在地图根节点上）调
## `track()` / `setSpatial()` 把「显示什么」交进来，HUD 每帧自己去相机上读位置和缩放。
## HUD 自己不碰相机、不碰声音，也不认输入 —— 它只负责画。
##
## 场景结构见 scene/demo_hud.tscn：
##   SpotOverlay  Node2D，画音频点（AudioStreamPlayer2D 本身没有任何画面，
##                不画出来录视频时看不出声源在哪）
##   Readout      Label，左上角实时读数

## 音频点标记的屏幕半径（像素）
const SPOT_RADIUS := 26.0
## 位置音开着 / 关掉时圆圈的颜色：青色 = 有远近，红色 = 距离衰减被摊平了
const SPOT_COLOR_ON := Color(0.35, 0.95, 1.0, 0.85)
const SPOT_COLOR_OFF := Color(1.0, 0.45, 0.35, 0.85)

var _cam: Camera2D
var _spots: Array[AudioStreamPlayer2D] = []
var _spatial := true
var _label: Label
var _overlay: Node2D


func _ready() -> void:
	_label = get_node_or_null("Readout") as Label
	_overlay = get_node_or_null("SpotOverlay") as Node2D
	if _overlay != null:
		# 借 Node2D 的 draw 信号做「外挂绘制」：绘制代码留在这个脚本里，
		# 覆盖层就不用再配第二个脚本。
		_overlay.draw.connect(drawSpots)
	else:
		push_warning("DemoHud: 找不到 SpotOverlay，音频点画不出来")


## 控制器（script/demo_map.gd）在它的 _ready 里调用。两个函数只写变量、不碰子节点，
## 所以在树里什么时候调都安全 —— 子节点先 _ready，HUD 那时已经准备好了。
func track(camera: Camera2D, spots: Array[AudioStreamPlayer2D]) -> void:
	_cam = camera
	_spots = spots


func setSpatial(on: bool) -> void:
	_spatial = on


func _process(_delta: float) -> void:
	if _label != null:
		_label.text = readout()
	if _overlay != null:
		_overlay.queue_redraw()


## 左上角那块读数。全部从相机上现读，所以拖 / 缩的时候画面里就是实时值。
##
## HUD 故意只把相机当「通用 Camera2D」用：`zoomMin` / `zoomMax` / `mapRect` 是
## custom_camera.gd 自己加的属性，走 get() 读，这样 HUD 不会绑死在某个相机脚本上。
func readout() -> String:
	var view := _viewportSize() / zoom()
	var centre := _cam.get_screen_center_position() if _cam != null else Vector2.ZERO
	var pos := _cam.global_position if _cam != null else Vector2.ZERO
	return "\n".join([
		"zoom   %.2f   (min %.1f  max %.1f)" % [
			zoom(), float(camProp("zoomMin", 1.0)), float(camProp("zoomMax", 1.0))],
		"camera top-left  (%.0f, %.0f)" % [pos.x, pos.y],
		"visible world    %.0f x %.0f" % [view.x, view.y],
		"visible centre   (%.0f, %.0f)" % [centre.x, centre.y],
		"level rect       %s" % str(camProp("mapRect", Rect2())),
		"audio spots      %d   spatial=%s" % [_spots.size(), "ON" if _spatial else "OFF"],
		"",
		"wheel = zoom at cursor    drag = pan",
		"R = reset    1 / 2 / 3 = zoom    S = spatial on/off",
	])


## 把音频点画出来。
##
## ⚠️ 这里**不能**改成在相机节点上 `_draw()`：`draw_arc` 用的是节点自己的局部坐标，
##    而相机是 FIXED_TOP_LEFT，画出来的位置会被相机自身的位置再偏一次
##    （屏幕坐标会变成 world * zoom，而不是 (world - 左上角) * zoom）。
##    实测过：zoom = 1、相机左上角 (1024, 612) 时，画在相机上的圈落在屏幕 (1056, 928)，
##    而容器真正在屏幕 (32, 316) —— 差的就是相机自己的位置。
##    HUD 挂在 CanvasLayer 下没有世界变换，所以这里自己把世界坐标换算成屏幕坐标，
##    换算用的「可视区左上角」是从相机报的可视中心反推的 —— 和 AudioListener2D
##    听在哪用的是同一个值，圈和声音不会对不上（tools/verify.gd 会拿引擎自己的
##    canvas transform 对一遍，误差要求 < 0.01 px）。
func drawSpots() -> void:
	if _cam == null or _overlay == null:
		return
	var c: Color = SPOT_COLOR_ON if _spatial else SPOT_COLOR_OFF
	for p in _spots:
		var at := toScreen(p.global_position)
		# 内圈：声源本身（固定屏幕大小，缩放时只是位置变）
		_overlay.draw_arc(at, SPOT_RADIUS, 0.0, TAU, 40, c, 2.0, true)
		# 外圈：衰减半径，是**世界**尺寸，所以要跟着缩放一起放大
		_overlay.draw_arc(at, p.max_distance * zoom(), 0.0, TAU, 72,
			Color(c.r, c.g, c.b, 0.16), 1.0, true)
		_overlay.draw_circle(at, 5.0, c)


## 世界坐标 → 屏幕坐标
func toScreen(world: Vector2) -> Vector2:
	var z := zoom()
	var centre := _cam.get_screen_center_position()
	var top_left: Vector2 = centre - _viewportSize() / (2.0 * z)
	return (world - top_left) * z


func zoom() -> float:
	return _cam.zoom.x if _cam != null else 1.0


func camProp(_name: String, fallback: Variant) -> Variant:
	if _cam == null:
		return fallback
	var v: Variant = _cam.get(_name)
	return fallback if v == null else v


func _viewportSize() -> Vector2:
	return get_viewport().get_visible_rect().size
