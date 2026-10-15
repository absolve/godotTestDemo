# godot4CameraAudioRange

相机缩放 / 拖拽 + 2D 声音远近 演示。

从塔防项目里**原样抽出**的相机实现，配合第一关的 tile 背景和装饰物，专门用来观察：

- 滚轮**以鼠标为中心**缩放，缩放范围夹在 `zoomMin` ~ `zoomMax`
- 按住左键拖动平移
- 相机**永远不越出关卡矩形**（敌人从边缘生成，露出关外就穿帮了）
- `AudioListener2D` 每帧同步到**可视区中心**，所以 `AudioStreamPlayer2D` 的
  左右声像和距离衰减跟玩家实际看到画面对得上
- 声音**长在装饰物身上**：`container` / `storage_tank` 场景各带一个循环的
  `AudioStreamPlayer2D`，地图里一个声音节点都没有

## 运行

用 Godot 4.7+ 打开本目录，F5。主场景是 `scene/map.tscn`（本目录用 4.7.2 验证过）。

| 操作 | 效果 |
| --- | --- |
| 滚轮 | 以光标位置为中心缩放 |
| 按住左键拖动 | 平移 |
| `R` | 复位（整关铺满） |
| `1` / `2` / `3` | 直接切到某个缩放档位 |
| `S` | 位置音 开/关（A/B 对比用） |
| `空格` | 全部音效 播放/停止 |

左上角有一块实时读数（zoom、相机左上角、可视世界尺寸、可视中心、关卡矩形、音频点数），
由 `DemoHud` 这一层 `CanvasLayer` 画出来。青色圆圈是音频点位置，外面那圈淡弧是它的
`max_distance` 衰减半径 —— **AudioStreamPlayer2D 本身没有任何画面**，不画出来录视频时
看不出声源在哪。按 `S` 关掉位置音时圆圈会变红，可以直接拍到"有没有做远近"的对比。

## 目录

```
project.godot            窗口 1920x1080（视口拉伸）、GL Compatibility、像素贴图不过滤
autoload/stage_data.gd   仅保留 TileSize 的替身（prop.gd 会读）
scene/custom_camera.tscn 相机场景：Camera2D(anchor_mode=0) + AudioListener2D
scene/demo_hud.tscn      演示 HUD：CanvasLayer + SpotOverlay(Node2D) + Readout(Label)
scene/map.tscn           演示关卡（生成物）：根节点挂 demo_map.gd，子节点 bg/props/Camera/DemoHud
scene/level/factory_floor.tres   第一关的 TileSet
scene/prop/*.tscn        6 种装饰物；container / storage_tank 自带循环音效
script/custom_camera.gd  ★ 相机实现（原样拷贝，未改动）
script/demo_map.gd       演示控制器：快捷键 + 找音频点 + 位置音/声音开关（挂地图根节点）
script/demo_hud.gd       演示 HUD：读数 + 音频点圆圈（只画，不管别的）
sprite/tile/*.png        24 张 tile
sprite/prop/*.png        装饰物图集
sound/sfx/*.ogg          只用得到的两个循环：container_rattle / tank_compressor
tools/                   生成与自检脚本
```

`script/custom_camera.gd` 是**参考实现**，没有为了演示改过一行，而且演示脚本也**没有叠在相机上**：
`scene/map.tscn` 里的 Camera 就是 `scene/custom_camera.tscn` 的实例，脚本始终是它自己那份。
演示专用的东西挂在**地图根节点**（`script/demo_map.gd`）和 **DemoHud 节点**
（`script/demo_hud.gd` + `scene/demo_hud.tscn`）上。

## 谁挂在哪

| 节点 | 脚本 | 职责 |
| --- | --- | --- |
| `Map`（map.tscn 根） | `demo_map.gd` | 快捷键、找音频点、开/关位置音、开/关声音；**只负责给** |
| `Camera`（custom_camera 实例） | `custom_camera.gd` | 缩放 / 拖拽 / 边界 / 同步听者；演示脚本一行没加 |
| `DemoHud`（demo_hud.tscn 实例） | `demo_hud.gd` | 读数、音频点圆圈；**只负责画**，不认输入、不碰声音 |

三件事的边界就是这三行：行为在地图、镜头在相机、画面在 HUD。
`DemoHud` 是**存进 map.tscn 的节点**（不是运行时拼出来的），所以在编辑器里能直接选中它调位置和样式。

代价是：`zoomMin` / `zoomMax` / `mapRect` / `targetZoom` / `targetPos` 和
`resetView()` / `clampPos()` 都是 `custom_camera.gd` 自己加的成员，不是 `Camera2D` 的，
所以 `demo_map.gd` 里只能 `get()` / `set()` / `call()`。这是故意的 ——
换来相机那头一行都不用改，`map.tscn` 里 Camera 的脚本也永远是 `custom_camera.gd`。

## 相机为什么这么写

`anchor_mode = FIXED_TOP_LEFT` —— `global_position` 表示可视区**左上角**，不是中心。
于是"不越界"就简化成一句：

```
左上角 ∈ [关卡左上角, 关卡右下角 - 视口世界尺寸]
```

因为相机中心不再是 `global_position`，`AudioListener2D` **不能**留在相机节点原点上，
否则声像会整体歪向一边。所以每帧把它同步到 `get_screen_center_position()`。

拖动用的是 `event.relative`（每帧屏幕位移）**除以当前 zoom** 后累积。
注释里记了两个踩过的坑：

1. 用"按下点 - 当前点"的**世界坐标**差 —— 那个值会跟着相机变，
   等价于 `target = 2 * 起点 - 当前位置`，每帧把相机往反方向甩。
2. 改成屏幕差除以 zoom —— 拖动时缩放动画还没收敛，zoom 每帧在变，
   目标位置被持续推着走（慢速漂移）。

`relative` 累积对两者都免疫。

## 显示为什么单独一层

读数、音频点圆圈、`CanvasLayer` 本身都在 `scene/demo_hud.tscn` 里；地图根节点的
`demo_map.gd` 通过 `track()` / `setSpatial()` 把「显示什么」交进去，HUD 每帧自己去相机上
读位置和缩放。控制器给、视图画，HUD 不反过来问，也不认输入。

- `CanvasLayer` 天生不参与 2D 世界变换，而且保证画在地图之上。这不是随手选的：
  把 Label 挂在**相机自己**身上，相机是 `FIXED_TOP_LEFT`，节点位置表示可视区左上角，
  UI 会被相机变换拖着跑；改挂父节点 + `top_level = true` 也没用 ——
  `top_level` 是 `Node3D` 的属性，对 `CanvasItem` 不起作用，HUD 会干脆完全不显示。
- HUD 是**存进 map.tscn 的节点**。上一版是控制器在运行时 `add_child` 出来的，
  编辑器里根本看不见，也就没法调位置和样式。

音频点的圆圈**不能**改成在相机节点上 `_draw()`：`draw_*` 用的是节点自己的局部坐标，
画出来的位置会被相机自身的位置再偏一次（屏幕坐标变成 `world * zoom`，
而不是 `(world - 左上角) * zoom`）。这不是纸上推的，是量过的：
zoom = 1、相机左上角 (1024, 612) 时，画在相机上的圈落在屏幕 **(1056, 928)**，
而容器真正在屏幕 **(32, 316)**。HUD 挂在 `CanvasLayer` 下没有世界变换，自己把世界坐标
换算成屏幕坐标，`tools/verify.gd` 拿引擎自己的 canvas transform 对一遍，误差 < 0.01 px。

## 声音放在哪

声音节点**不在 `scene/map.tscn` 里**，而是在装饰物场景里：

```
scene/prop/container.tscn      Sound: container_rattle.ogg    max_distance 1000  volume -10 dB
scene/prop/storage_tank.tscn   Sound: tank_compressor.ogg     max_distance 1400  volume -10 dB
```

两个节点都在 `audio_spot` 组里，`demo_map.gd` 用组查询拿到全部音效点，`S` / `空格`
就是对它们下手。这样"储罐听起来什么样"和"储罐看起来什么样"在同一个文件里，
生成脚本也不用再往地图里塞声音（`gen_props.gd` 反而会**删掉**老地图留下的 `audioSpots`）。

- 循环靠 `.ogg` 的**导入设置** `loop=true`（`sound/sfx/*.ogg.import`），
  不在运行时改共享资源；`tools/verify.gd` 会检查每个音效点确实在循环、确实在播。
- 两个循环是**无缝**的：不是切一段再淡入淡出（那样每圈会"呼吸"一下），
  而是用交叉淡化接的 —— 循环体前面 F 秒和循环体后面 F 秒互相对叠，
  于是 `out[0]` 接着 `out[-1]`、接缝处和文件内部一样平滑。
- 音量 / 衰减距离都在场景里，想调直接改 `Sound` 节点的 `volume_db` / `max_distance`。

### 为什么「关位置音」要一个个设，而不是 clear_current()

`AudioListener2D.clear_current()` **关不掉**位置音：没有听者时 `AudioStreamPlayer2D` 会回退到
**当前 Camera2D 的可视中心**，继续算远近和声像。实测（`AudioEffectCapture` 直接读 Sfx 总线
输出，声源放在 900px 外、`max_distance = 1000`，源素材自身有约 -1.8 dB 的左右不平衡）：

| 状态 | L | R | L−R（声像） |
| --- | --- | --- | --- |
| 听者 current | -46.3 dB | -40.4 dB | -6.0 dB |
| 听者 `clear_current()`（viewport 里已无听者） | -48.0 dB | -41.8 dB | -6.2 dB |
| 上一条再把声源挪到 4000px 外 | -140 dB | -140 dB | 0（距离衰减照旧在算） |
| 把相机挪走后再 `clear_current()` | -140 dB | -140 dB | 0（听者变成了相机中心） |

这个 demo 的相机本来就把听者每帧同步到 `get_screen_center_position()` —— 和引擎的回退点是
同一个位置，所以清掉听者等于什么都没做。两个旋钮也各管一件事：`max_distance` 管远近
（拉到 1e5 后音量回到 -22.8 dB），`panning_strength` 管左右（不设 0 的话 pan 仍有 -5.9 dB），
要真的「摊平」得两个都设。

## 关卡数据哪来的

`scene/map.tscn` 是**生成**的，不是手写的。第一关的 tile 数据是二进制
`PackedByteArray`（每格 6 字节：`x, y, sourceId`），手写 atlas 坐标很容易悄悄生成一张空图。

```
tools/seed_level.tscn   从正式项目里抽出来的 bg 层（含原始 tile 数据）
tools/gen_map.gd        读 seed，2x2 平铺成 3968x2304 的世界，四周补一圈地板
tools/gen_props.gd      放入装饰物、相机、DemoHud，并给地图根节点挂上 demo_map.gd
                        （声音跟着装饰物场景一起进来，这里一个声音节点都不创建）
tools/verify.gd         自检 + 三个缩放档位截图
```

`gen_props` 只给相机改 `mapRect` 这一个**导出属性**，从不 `set_script()` ——
所以生成出来的 `map.tscn` 里，Camera 的脚本永远是 `custom_camera.gd`。

重跑：

```bash
godot --headless --path . res://tools/gen_map.tscn
godot --headless --path . res://tools/gen_props.tscn
godot --path . res://tools/verify.tscn      # 截图写到 user://shot/
```

两个生成脚本都是**可重复执行**的（`gen_props` 会先删掉上次生成的
`props` / `Camera` / `DemoHud`，以及老版本留下的 `audioSpots`）。
`DemoHud` 和根节点上的 `demo_map.gd` 都由 `gen_props` 写进 `map.tscn`，
所以重新生成不会把它们弄丢，也不用手工去场景里补。

`verify.tscn` 会把结果打出来，其中这几行是 demo 的结论（数字是**重新生成过的 map** 的结果，
即 84 个装饰物 / 8 个音效点；`verify` 全都是按组和场景现查的，手动改了 map 就跟着变）：

```
@@ scene map script    res://script/demo_map.gd
@@ scene camera script res://script/custom_camera.gd
@@ scene hud node      saved in map.tscn
@@ sound check   non-looping=0 not-playing=0 outside-props=0
@@ map players   8 total, 8 under props
@@ legacy audioSpots absent (good)
zoom 1.00  visible 1920x1080  top-left (1024,612)  inside=true  listener centre-delta=0.0
zoom 2.00  visible  960x540   top-left (1504,882)  inside=true  listener centre-delta=0.0
zoom 3.00  visible  640x360   top-left (1664,972)  inside=true  listener centre-delta=0.0
@@ hud mapping   worst world->screen delta 0.000 px over 8 spots
@@ spatial OFF   8/8 spots flattened  hud=audio spots      8   spatial=OFF
@@ spatial ON    8/8 spots restored  max_distances=[1400.0, 1000.0, ...]
@@ space toggle  stopped 8/8, then playing 8/8
@@ key 2         targetZoom=2.00 (camera zoom=2.78)
```

- `scene ... script` —— 相机保持参考实现，演示脚本在地图根节点上
- `scene hud node  saved in map.tscn` —— HUD 是在场景里的节点，不是运行时拼的
  （这一行是在实例化后、`add_child` **之前**查的，运行时创建的节点不可能出现在那里）
- `inside=true` —— 相机没越界
- `centre-delta=0.0` —— 听者精确落在可视区中心
- `outside-props=0` —— 地图里没有"野生"的声音节点
- `hud mapping ... 0.000 px` —— 圆圈画在声源上，不是画在别处
- `spatial OFF/ON 8/8`、`key 2` —— 这几个是 `Input.parse_input_event()` **真的按键**走的完整
  输入管线（不是直接调方法），所以「快捷键搬到了地图根节点」这件事是真验过的

## 与原项目的差异

- `StageData` 只留了 `TileSize = 64`。原项目里它是个 1100 行的关卡表（依赖 `Game` 的枚举），
  演示用不到，但 `prop.gd` 里写了 `StageData.TileSize`，所以留个替身让它原样能跑。
- 装饰物的 `snapToGrid` 全部关掉：它们在原关卡里已经落在格子中心，再让它去读
  `StageData` 重新吸附是多余的。
- 装饰物多了一个 `Sound` 子节点（原项目里装饰物是不发声的）—— 演示要把声源和画面绑在一起。
- 演示脚本原来叫 `demo_camera.gd`，`extends custom_camera.gd` 叠在相机上；现在拆成了
  地图根节点的 `demo_map.gd` 和 HUD 的 `demo_hud.gd`，相机那头一点没动。
- 没有敌人、塔、子弹、UI、成就、多语言 —— 相机和声音才是这个 demo 的主题。

## 素材来源

tile / 装饰物来自塔防项目本体。
`sound/sfx` 里只有这两个循环，都是从 Sonniss #GameAudioGDC 包里剪的（免版税、无需署名）；
塔防项目原本带的那 8 个短音效（`cannon_fire` / `coin` / `enemy_incoming` / `explode_small` /
`mech_crawl` / `mg_fire` / `toolbox_click` / `tower_deploy`）在声音改挂到装饰物之后就没有任何
场景引用了，已经连同 `.import` 和 Godot 的导入缓存一起删掉：

| 文件 | 原素材 | 剪法 |
| --- | --- | --- |
| `container_rattle.ogg` | Pole Position - The Stormbat Hull Interaction Library：*Metal - RATTLE - Shudder Constant - Geofon* | 2.0s 起取 10s，1s 交叉淡化 |
| `tank_compressor.ogg` | Mononeshot - Industrial, Ironworks：*Oxygen compressor 04* | 15.0s 起取 12s，1s 交叉淡化 |

选这两个是因为它们的响度最平（源文件里逐段量过 RMS，取最稳的一段），
压成大罐子/压缩机的持续底噪，而不是一阵一阵的效果音。
