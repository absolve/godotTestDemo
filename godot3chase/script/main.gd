# 主场景脚本
# 负责加载地图和管理游戏世界
extends Node2D

# 常量定义
const size=32  #  tilesize

# 变量定义
var width  # 视口宽度
var height  # 视口高度
var mapWidth  # 地图宽度
var mapHeight  # 地图高度

# 资源预加载
var tile=preload("res://scene/tile.tscn")  # 加载tile场景
onready var player=$tank  # 玩家引用

# 节点就绪时调用
func _ready():
	# 设置背景颜色
	VisualServer.set_default_clear_color(Color('#9c9c9c'))
	# 居中窗口
	OS.center_window()
	# 设置全局地图引用
	Game.map=self
	
	# 加载地图
	loadMap("res://level/test0.json")
	# 获取视口大小
	width=get_viewport_rect().size.x
	height=get_viewport_rect().size.y
	
	
# 加载地图函数
# 参数: fileName - 地图文件路径
func loadMap(fileName:String):
	var file = File.new()
	if file.file_exists(fileName):
		file.open(fileName, File.READ)
		var content=parse_json(file.get_as_text())
		mapWidth=int(content['mapWidth'])
		mapHeight=int(content['mapHeight'])
		# 遍历地图数据
		for i in content['data']:
			if i['type'] =='tile':
				# 创建tile实例
				var temp=tile.instance()
				temp.position.x=i['x']*size+size/2
				temp.position.y=i['y']*size+size/2
				add_child(temp)

# 获取玩家引用
# 返回: 玩家节点
func getPlayer():
	return player
