# 消息提醒系统自动加载脚本
# 实现消息提醒的显示和管理
extends Node

# 枚举定义
enum direction{top,bottom}  # 消息显示方向
enum mode{toast,message}  # 消息模式

# 变量定义
var bottomLabel=[]  # 底部toast消息列表
var topLabel=[]  # 顶部toast消息列表
var bottomMoveLabel=[]  # 底部message消息列表
var topMoveLabel=[]  # 顶部message消息列表
var label=preload("res://addons/my_toast/scene/toastLabel.tscn")  # 消息标签场景

# 显示消息函数
# 参数: _str - 消息内容, _dir - 显示方向, _mode - 消息模式
func display(_str:String,_dir:direction,_mode:mode=mode.toast):
	# 实例化消息标签
	var temp=label.instantiate()
	# 连接移除信号
	temp.remove.connect(removeLabel)
	# 设置消息内容
	temp.str=_str
	# 设置显示方向
	if _dir==direction.top:
		temp.dir='top'
	elif _dir==direction.bottom:
		temp.dir='bottom'
	# 添加到场景
	add_child(temp)
	
	# 根据模式添加到不同的列表
	if _mode==mode.toast:
		if _dir==direction.top:
			topLabel.push_front(temp)
		else:
			bottomLabel.push_front(temp)
	else:
		if _dir==direction.top:
			topMoveLabel.push_front(temp)
			# 调整消息位置
			for i in range(topMoveLabel.size()):
				if topMoveLabel[i]!=null:
					topMoveLabel[i].movePos(i)
		else:
			bottomMoveLabel.push_front(temp)
			# 调整消息位置
			for i in range(bottomMoveLabel.size()):
				if bottomMoveLabel[i]!=null:
					bottomMoveLabel[i].movePos(i)

# 移除消息函数
# 参数: node - 要移除的消息节点
func removeLabel(node):
	# 从各个列表中移除节点
	for i in topLabel:
		if i == node:
			topLabel.erase(i)
			break
	for i in bottomLabel:
		if i ==	node:
			bottomLabel.	erase(i)
			break
	for i in bottomMoveLabel:
		if i ==	node:
			bottomMoveLabel.erase(i)
			break
	for i in topMoveLabel:
		if i ==	node:
			topMoveLabel.erase(i)
			break
