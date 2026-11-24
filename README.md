# godotTestDemo

## 项目简介
这是一个包含多个 Godot 游戏引擎测试项目的集合，每个文件夹代表一个独立的 Godot 项目，展示了不同的游戏开发功能和效果。

## Godot 版本信息
- **Godot 3.x 项目**：大多数项目使用 Godot 3.x 版本
- **Godot 4.x 项目**：分别使用 Godot 4.5 / 4.6 / 4.7 版本

## 项目结构
每个文件夹都是一个独立的 Godot 项目，包含以下典型结构：
- `scene/`：场景文件
- `script/`：脚本文件
- `sprite/`：精灵和图像资源
- `project.godot`：项目配置文件

## 项目列表

### Godot 3.x 项目
- **godot3chase**：敌人追逐功能演示
- **godot3Cursor**：自定义鼠标光标实现
- **godot3fogOfWar**：战争迷雾效果
- **godot3LevelSelect**：关卡选择界面
- **godot3Line2d**：Line2d 节点的使用示例
- **godot3ntLight**：灯光效果演示
- **godot3SlotGame**：简单的抽奖功能
- **godot3xray**：X-ray 效果
- **godot3FlashLight**：手电筒效果
- **godot3inputCombo**：按键连招功能
- **godot3DestructibleTerrain**：简单的可破坏地形
- **godot3SfxManage**：声音管理系统
- **godot3AfterImage**：残影效果
- **godot3SpriteFlip**：精灵翻转功能
- **godot3ClimbWall**：角色爬墙功能
- **godot3Clip**：图片裁剪功能
- **godot3HealthBar**：健康条实现
- **godot3TimeSlow**：时间减慢效果

### Godot 4.x 项目
- **godot-4-camera-drag-zoom**：相机平移缩放功能（使用 Godot 4.5）
- **godot4CameraAudioRange**：在相机平移缩放的基础上加了 2D 声音远近演示（使用 Godot 4.7），声音挂在装饰物场景里，地图本身不含声音节点
- **godot-4-toast**：消息提醒系统（使用 Godot 4.x）
- **godot4flow-field**：流场寻路算法演示（使用 Godot 4.x），通过预计算流向场实现高效路径寻路，适合大量单位同时寻路的场景，支持单目标和多目标两种模式

## godot4CameraAudioRange（相机缩放 / 拖拽 + 声音远近）

2D 相机缩放 / 拖拽 + 声音远近演示，Godot 4.7（用 4.7.2 验证过）。主场景 `scene/map.tscn`，
视口 1920x1080，用塔防项目第一关的 tile 与装饰物铺出 3968x2304 的关卡。

**演示内容**

- 滚轮**以鼠标为中心**缩放（`zoomMin` 1.0 ~ `zoomMax` 3.0），按住左键拖动平移，
  相机**永远不越出关卡矩形**（敌人从边缘生成，露出关外就穿帮了）
- `AudioListener2D` 每帧同步到**可视区中心**，所以 `AudioStreamPlayer2D` 的左右声像和
  距离衰减跟玩家实际看到的画面对得上
- 声音**长在装饰物身上**：`container` / `storage_tank` 场景各自带一个无缝循环音效，
  **地图里没有任何声音节点**（老版本生成的 `audioSpots` 会被生成脚本清掉）
- HUD 实时读数 + 音频点圆圈：青色 = 有远近，按 `S` 关掉位置音变红，衰减半径圈跟着放大

**操作**：滚轮缩放 · 按住左键拖动 · `R` 复位 · `1` / `2` / `3` 切缩放档位 ·
`S` 位置音开/关 · `空格` 声音播放/停止

更细的东西（相机为什么这么夹边界、听者为什么不能留在相机原点上、
`AudioListener2D.clear_current()` 为什么关不掉位置音、两个循环音效是怎么剪成无缝的）
都写在 [godot4CameraAudioRange/README.md](godot4CameraAudioRange/README.md) 里。

## 许可证
本项目采用 MIT 许可证，详情请参阅 [LICENSE](LICENSE) 文件。
