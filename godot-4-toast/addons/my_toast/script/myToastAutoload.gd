extends Node

enum direction{top,bottom}
var bottomLabel=[]
var topLabel=[]
var label=preload("res://addons/my_toast/scene/toastLabel.tscn")


#显示弹窗
func display(_str:String,_dir:direction):
	var temp=label.instantiate()
	temp.remove.connect(removeLabel)
	temp.str=_str
	add_child(temp)
	if _dir==direction.top:
		temp.dir='top'
		topLabel.push_front(temp)
		for i in range(topLabel.size()):
			topLabel[i].movePos(i)
	elif _dir==direction.bottom:
		temp.dir='bottom'
		bottomLabel.push_front(temp)
		for i in range(bottomLabel.size()):
			bottomLabel[i].movePos(i)
	
	
	
func removeLabel(node):
	for i in topLabel:
		if i == node:
			topLabel.erase(i)
			break
	for i in bottomLabel:
		if i ==	node:
			bottomLabel.	erase(i)
			break
			
