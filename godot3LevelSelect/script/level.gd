extends PanelContainer


export var lock=true
export var levelNum=1

onready var _lock=$lock
onready var _num=$num

#设置是否锁住
func setLock(value:bool):
	lock=value
	_lock.visible=lock
	_num.visible=!lock

#设置关卡数字
func setLevel(value):
	levelNum=value
	_num.text=str(value)

func _gui_input(event):
	if lock:
		return
	if event is InputEventMouseButton and event.pressed:	
		print('click ',levelNum)
	
