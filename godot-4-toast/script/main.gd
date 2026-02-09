extends Node2D


var count=100


func _on_button_pressed():
	count-=1
	myToast.display("再点击%s次进入开发者模式"%count,myToast.direction.bottom)
	


func _on_top_pressed():
	myToast.display("hello world",myToast.direction.top)


func _on_message_pressed():
	myToast.display("hello world",myToast.direction.top,myToast.mode.message)


func _on_message_2_pressed():
	myToast.display("hello world",myToast.direction.bottom,myToast.mode.message)
