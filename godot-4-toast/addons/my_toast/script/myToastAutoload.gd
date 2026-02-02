extends Node


var bottomLabel=[]
var topLabel=[]

var label=preload("res://addons/my_toast/scene/toastLabel.tscn")

#显示弹窗
func display(_str:String,_dir):
	var temp=label.instantiate()
	temp.dir=_dir
	temp.remove.connect(removeLabel)
	temp.str=_str
	add_child(temp)
	if _dir=='top':
		topLabel.push_back(temp)
	elif _dir=='bottom':
		bottomLabel.push_back(temp)

func removeLabel(node):
	for i in topLabel:
		if i == node:
			topLabel.erase(i)
			break
	for i in bottomLabel:
		if i ==	node:
			bottomLabel.	erase(i)
			break
			
