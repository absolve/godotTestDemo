extends Node

#连招列表
var combos=[{
	'name':"skill1",
	'combos':[["left","punch"],["right","punch"]],
	'priority':0,
},{
	'name':"skill2",
	'combos':[["left",'right',"punch"],["right",'left',"punch"]],
	'priority':1,
},{
	'name':"skill3",
	'combos':[["up",'down',"punch"]],
	'priority':0,
}]

#玩家状态
enum state{
	idle,
	move,
	attack,
	jump,
	skill,
}

enum direction{
	left,
	right
}
