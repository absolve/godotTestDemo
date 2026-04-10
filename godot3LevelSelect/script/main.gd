# 关卡选择主脚本
# 实现关卡选择界面和关卡锁定功能
extends Control

# 节点引用
onready var hbox=$VBoxContainer/MarginContainer/MarginContainer/hbox  # 水平容器

# 变量定义
var colNum=3	# 总共3块关卡
var width=600	# 每个关卡集合的宽度
var currCol=1	# 当前位置

# 节点就绪时调用
func _ready():
	# 居中窗口
	OS.center_window()
	var num=1
	# 遍历所有关卡节点
	for i in hbox.get_children():
		for y in i.get_children():
			y.setLevel(num)  # 设置关卡编号
			if num<=20:
				y.setLock(false)  # 解锁前20个关卡
			num+=1

# 左按钮点击事件
func _on_btnLeft_pressed():
	if currCol>1:
		currCol-=1  # 减少当前位置
		# 创建动画，移动关卡容器
		var tween =create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property(hbox,"rect_position:x",hbox.rect_position.x+width ,1)

# 右按钮点击事件
func _on_btnRight_pressed():
	if currCol<colNum:
		currCol+=1  # 增加当前位置
		# 创建动画，移动关卡容器
		var tween =create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property(hbox,"rect_position:x",hbox.rect_position.x-width ,1)
