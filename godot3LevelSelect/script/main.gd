extends Control



onready var hbox=$VBoxContainer/MarginContainer/MarginContainer/hbox

var colNum=3	#总共3块
var width=600	#每个关卡集合的宽度
var currCol=1	#当前位置

func _ready():
	OS.center_window()
	var num=1
	for i in hbox.get_children():
		for y in i.get_children():
			y.setLevel(num)
			if num<=20:
				y.setLock(false)
			num+=1


func _on_btnLeft_pressed():
	if currCol>1:
		currCol-=1
		var tween =create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property(hbox,"rect_position:x",hbox.rect_position.x+width ,1)


func _on_btnRight_pressed():
	if currCol<colNum:
		currCol+=1
		var tween =create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property(hbox,"rect_position:x",hbox.rect_position.x-width ,1)
