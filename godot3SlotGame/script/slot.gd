extends Control


var itemList=[0,1,2,3,4,5]
var index=0
var imgList=[]
var speed=100
var boxSize=64 #每个格子的高度
var img1=preload("res://sprite/NES - Snow Brothers Snow Bros Nick & Tom - Machine Bonus_33.png")
var img2=preload("res://sprite/NES - Snow Brothers Snow Bros Nick & Tom - Machine Bonus_34.png")
var img3=preload("res://sprite/NES - Snow Brothers Snow Bros Nick & Tom - Machine Bonus_29.png")
var img4=preload("res://sprite/NES - Snow Brothers Snow Bros Nick & Tom - Machine Bonus_30.png")
var img5=preload("res://sprite/NES - Snow Brothers Snow Bros Nick & Tom - Machine Bonus_32.png")
var img6=preload("res://sprite/NES - Snow Brothers Snow Bros Nick & Tom - Machine Bonus_31.png")
var currState=state.idle

onready var vbox=$vbox

enum state{
	idle,
	scroll,
	finish
}

func _ready():
	imgList.append(img5)
	imgList.append(img1)
	imgList.append(img2)
	imgList.append(img3)
	imgList.append(img4)
	imgList.append(img6)

	for i in range(5):
		var temp=TextureRect.new()
		temp.texture=imgList[i]
		temp.rect_position.y=boxSize*i
		vbox.add_child(temp)
		
#	currState=state.scroll
	
	
func _physics_process(delta):
	if currState==state.scroll:
		for i in vbox.get_children():
			i.rect_position.y-=speed*delta
		if vbox.get_child_count()>0:
			var node=vbox.get_child(0)
			if node.rect_position.y<-boxSize:
				vbox.remove_child(node)
		
