extends Control



onready var inputName=$hbox/Label

#设置输入名字
func setInputName(name):
	inputName.text=str(name)
