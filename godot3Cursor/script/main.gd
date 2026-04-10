# 主场景脚本
# 负责加载地图和管理场景切换
extends Node2D

# 资源预加载
var tile=preload("res://scene/tile.tscn")  # 加载tile场景

# 常量定义
const size=32  #  tilesize

# 变量定义
var width  # 视口宽度
var height  # 视口高度
var mapWidth  # 地图宽度
var mapHeight  # 地图高度

# 节点就绪时调用
func _ready():
	# 获取视口大小
	width=get_viewport_rect().size.x
	height=get_viewport_rect().size.y

	# 加载地图
	loadMap("res://test0.json")
	
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
				#				 temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*size+size/2
				temp.position.y=i['y']*size+size/2
				add_child(temp)

# 按钮点击事件处理函数
func _on_Button_pressed():
	set_process_input(false)  # 禁用输入处理
	get_tree().change_scene("res://scene/welcome.tscn")  # 切换到欢迎场景
	set_process_input(true)  # 启用输入处理
