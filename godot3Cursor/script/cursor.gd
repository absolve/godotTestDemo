# 自定义鼠标光标脚本
# 实现隐藏默认鼠标并使用动画精灵作为自定义光标
extends AnimatedSprite

# 节点就绪时调用
func _ready():
	pass # Replace with function body.

# 节点进入场景树时调用
func _enter_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)  # 隐藏默认鼠标

# 节点退出场景树时调用
func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # 显示默认鼠标

# 每帧处理函数
# 参数: delta - 时间增量
func _process(delta):
	position=get_global_mouse_position()  # 将光标位置设置为鼠标全局位置
	
