extends Node

enum direction{top,bottom}
enum mode{toast,message}
var bottomLabel=[]
var topLabel=[]
var bottomMoveLabel=[]
var topMoveLabel=[]
var label=preload("res://addons/my_toast/scene/toastLabel.tscn")


#显示弹窗
func display(_str:String,_dir:direction,_mode:mode=mode.toast):
	var temp=label.instantiate()
	temp.remove.connect(removeLabel)
	temp.str=_str
	if _dir==direction.top:
		temp.dir='top'
	elif _dir==direction.bottom:
		temp.dir='bottom'
	add_child(temp)
	if _mode==mode.toast:
		if _dir==direction.top:
			topLabel.push_front(temp)
		else:	
			bottomLabel.push_front(temp)
	else:
		if _dir==direction.top:
			topMoveLabel.push_front(temp)
			for i in range(topMoveLabel.size()):
				if topMoveLabel[i]!=null:
					topMoveLabel[i].movePos(i)
		else:	
			bottomMoveLabel.push_front(temp)
			for i in range(bottomMoveLabel.size()):
				if bottomMoveLabel[i]!=null:
					bottomMoveLabel[i].movePos(i)
	
	
func removeLabel(node):
	for i in topLabel:
		if i == node:
			topLabel.erase(i)
			break
	for i in bottomLabel:
		if i ==	node:
			bottomLabel.erase(i)
			break
	for i in bottomMoveLabel:
		if i ==	node:
			bottomMoveLabel.erase(i)
			break
	for i in topMoveLabel:
		if i ==	node:		
			topMoveLabel.erase(i)
			break
