# 主场景脚本
# 测试消息提醒功能
extends Node2D

# 变量定义
var count=100  # 点击计数

# 底部按钮点击事件
func _on_button_pressed():
	count-=1  # 减少计数
	# 显示底部消息
	myToast.display("再点击%s次进入开发者模式"%count,myToast.direction.bottom)
	
# 顶部按钮点击事件
func _on_top_pressed():
	# 显示顶部消息
	myToast.display("hello world",myToast.direction.top)

# 顶部消息按钮点击事件
func _on_message_pressed():
	# 显示顶部消息模式的提醒
	myToast.display("hello world",myToast.direction.top,myToast.mode.message)

# 底部消息按钮点击事件
func _on_message_2_pressed():
	# 显示底部消息模式的提醒
	myToast.display("hello world",myToast.direction.bottom,myToast.mode.message)
