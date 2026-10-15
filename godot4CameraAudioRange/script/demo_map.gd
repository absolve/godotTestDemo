extends Node2D

## 演示场景的控制器 —— 挂在 `scene/map.tscn` 的**根节点**上。
##
## 这里原本是 `script/demo_camera.gd`：它 `extends custom_camera.gd`，把演示行为**叠在
## 相机身上**。那样有两个问题：
##   1. 地图里的 Camera 就不再是「原样拷过来的参考实现」了 —— 场景文件里多出一行
##      `script = demo_camera.gd`，看代码的人分不清哪些行为是线上也有的；
##   2. 快捷键、找音频点、声音开关本来就不是「相机怎么动」，只是碰巧要操作相机。
## 所以现在相机保持纯净：`scene/map.tscn` 里的 Camera 就是 `scene/custom_camera.tscn`
## 的实例，脚本一个字没动；演示行为全在这一个文件里。
##
## 显示（读数、音频点圆圈、CanvasLayer 本身）在 `scene/demo_hud.tscn`，
## 由这里的 `track()` / `setSpatial()` 喂数据 —— 控制器给，视图画，HUD 不反过来问。
##
## 声音也不是地图摆的：每个 container / storage_tank 场景自带一个循环的
## AudioStreamPlayer2D（group = audio_spot），地图里一个声音节点都没有。
##
## ⚠️ 代价：`zoomMin` / `zoomMax` / `mapRect` / `targetZoom` / `targetPos` 和
##    `resetView()` / `clampPos()` 都是 `custom_camera.gd` 自己加的成员，不是
##    Camera2D 的，所以在 `_cam: Camera2D` 上只能走 `get()` / `set()` / `call()`。
##    这是故意的：换来相机那头一行都不用改。

## 装饰物自带的循环音效点所在的组（见 scene/prop/container.tscn、storage_tank.tscn）
const SPOT_GROUP := &"audio_spot"
## 「位置音关掉」时用的衰减距离：大到超出关卡，远近就都听不出来了
const FLAT_DISTANCE := 100000.0

## 位置音是否开着。HUD 读它决定圆圈画青色还是红色。
var spatial: bool = true

var _cam: Camera2D
var _hud: DemoHud
var _spots: Array[AudioStreamPlayer2D] = []
## 每个音效点自己配的衰减距离；开关位置音时要还原成这个值
var _baseDistance: Dictionary = {}


func _ready() -> void:
	_cam = get_node_or_null("Camera") as Camera2D
	_hud = get_node_or_null("DemoHud") as DemoHud
	if _cam == null:
		push_warning("DemoMap: 场景里没有 Camera 节点，快捷键和读数都用不了")
	collectSpots()
	applySpatial()
	if _hud != null:
		_hud.track(_cam, _spots)
		_hud.setSpatial(spatial)
	print("@@ demo map: %d prop audio spots  camera=%s  hud=%s" % [
		_spots.size(), "ok" if _cam != null else "MISSING", "ok" if _hud != null else "MISSING"])


## 找出装饰物自带的循环音效点。
## 用组而不是遍历节点树：容器 / 储罐的实例散在 props 下面，组查询一次就拿到，
## 加新装饰物时也只要在它的场景里写上同一个组名。
func collectSpots() -> void:
	_spots.clear()
	_baseDistance.clear()
	for n in get_tree().get_nodes_in_group(SPOT_GROUP):
		var p := n as AudioStreamPlayer2D
		if p == null:
			continue
		_baseDistance[p] = p.max_distance
		_spots.append(p)


## 把 spatial 这个开关同步到所有音效点（衰减距离 + 声像强度）
func applySpatial() -> void:
	for p in _spots:
		p.max_distance = float(_baseDistance.get(p, p.max_distance)) if spatial else FLAT_DISTANCE
		p.panning_strength = 1.0 if spatial else 0.0


## 复位成「整关刚好铺满」（相机自己的实现，这里只是转发）
func resetView() -> void:
	if _cam != null:
		_cam.call("resetView")


## 直接切到某一档缩放，并夹住位置（快捷键 1 / 2 / 3 用）
func setZoomLevel(z: float) -> void:
	if _cam == null:
		return
	var level := clampf(z, camNum("zoomMin", 1.0), camNum("zoomMax", 3.0))
	_cam.set("targetZoom", level)
	_cam.set("targetPos", _cam.call("clampPos", camVector("targetPos"), level))


## 关掉位置音：把衰减距离设成极大、声像强度设成 0，远近和左右就都听不出来了。
## 录视频时按这一下，能直接 A/B 对比「有没有做位置音」。
##
## ⚠️ 别把它「简化」成 `audioListener.clear_current()` —— 那样关不掉位置音。
##    实测（AudioEffectCapture 读 Sfx 总线输出，声源放在 900px 外、max_distance = 1000）：
##      · 听者 current：L -46.3 / R -40.4 dB（pan -6.0 dB）
##      · `clear_current()` 之后（viewport 里确实已经没有听者）：L -48.0 / R -41.8 dB，
##        pan -6.2 dB —— 和上面一模一样，位置音一点没关；把声源挪到 4000px 外照样
##        直接静音，说明**距离衰减还在算**。原因是：没有听者时 `AudioStreamPlayer2D`
##        会回退到**当前 Camera2D 的可视中心**（把相机挪开，声源立刻变静音；把声源放回
##        相机中心，音量马上回来）。而这个 demo 的相机本来就把听者每帧同步到
##        `get_screen_center_position()`，也就是引擎回退到的同一个点 —— 清掉听者
##        等于什么都没做。
##    另外两个旋钮各管一件事：只把 `max_distance` 拉大只去掉「远近」，左右声像还在
##    （pan 仍是 -5.9 dB），必须连 `panning_strength` 一起设才叫摊平。
func toggleSpatial() -> void:
	spatial = not spatial
	applySpatial()
	if _hud != null:
		_hud.setSpatial(spatial)
	print("@@ spatial %s" % ("ON" if spatial else "OFF"))


func toggleSound() -> void:
	if _spots.is_empty():
		return
	var any_playing := false
	for p in _spots:
		if p.playing:
			any_playing = true
			break
	for p in _spots:
		if any_playing:
			p.stop()
		else:
			p.play()
	print("@@ sound %s" % ("stopped" if any_playing else "playing"))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_R:
				resetView()
			KEY_1:
				setZoomLevel(1.0)
			KEY_2:
				setZoomLevel(2.0)
			KEY_3:
				setZoomLevel(3.0)
			KEY_S:
				toggleSpatial()
			KEY_SPACE:
				toggleSound()


# ---- custom_camera.gd 自己的属性只能这么读（见文件头的 ⚠️）----

func camNum(prop: String, fallback: float) -> float:
	if _cam == null:
		return fallback
	var v: Variant = _cam.get(prop)
	return float(v) if v != null else fallback


func camVector(prop: String) -> Vector2:
	if _cam == null:
		return Vector2.ZERO
	var v: Variant = _cam.get(prop)
	return Vector2(v) if v is Vector2 else Vector2.ZERO
