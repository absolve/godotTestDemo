extends Control


var itemList=[0,1,2,3,4,5]
var index=0
var imgList=[]
var speed=200
var boxSize=32 #每个格子的高度
var img1=preload("res://sprite/NES - Snow Brothers Snow Bros Nick & Tom - Machine Bonus_33.png")
var img2=preload("res://sprite/NES - Snow Brothers Snow Bros Nick & Tom - Machine Bonus_34.png")
var img3=preload("res://sprite/NES - Snow Brothers Snow Bros Nick & Tom - Machine Bonus_29.png")
var img4=preload("res://sprite/NES - Snow Brothers Snow Bros Nick & Tom - Machine Bonus_30.png")
var img5=preload("res://sprite/NES - Snow Brothers Snow Bros Nick & Tom - Machine Bonus_32.png")
var img6=preload("res://sprite/NES - Snow Brothers Snow Bros Nick & Tom - Machine Bonus_31.png")

var currState=Game.state.idle

onready var vbox=$vbox
var card=preload("res://scene/card.tscn")
var slotList=[]


func _ready():
#	imgList.append(img5)
#	imgList.append(img1)
#	imgList.append(img2)
#	imgList.append(img3)
#	imgList.append(img4)
#	imgList.append(img6)
#
#	for i in range(imgList.size()):
#		var temp=TextureRect.new()
#		temp.texture=imgList[i]
#		temp.rect_position.y=boxSize*i
#		vbox.add_child(temp)
	
	slotList.append(Game.cardType.man)
	slotList.append(Game.cardType.s)
	slotList.append(Game.cardType.n)
	slotList.append(Game.cardType.o)
	slotList.append(Game.cardType.w)
	slotList.append(Game.cardType.x)
	for i in range(slotList.size()):
		var temp=card.instance()
		temp.type=slotList[i]
		temp.rect_position.y=boxSize*i
		vbox.add_child(temp)
		
	currState=Game.state.scroll
	
	
func _physics_process(delta):
	if currState==Game.state.scroll:
		for i in vbox.get_children():
			i.rect_position.y-=speed*delta
		if vbox.get_child_count()>0:
			var node=vbox.get_child(0)
			if node.rect_position.y<-boxSize:	#如果超过了屏幕就往地下增加一个
				vbox.remove_child(node)
				var last=vbox.get_child(vbox.get_child_count()-1) #最后一个
				var temp=card.instance()
				if last.type==Game.cardType.man:	
					temp.type=Game.cardType.s
				elif last.type==Game.cardType.s:
					temp.type=Game.cardType.n
				elif last.type==Game.cardType.n:
					temp.type=Game.cardType.o
				elif last.type==Game.cardType.o:	
					temp.type=Game.cardType.w
				elif last.type==Game.cardType.w:
					temp.type=Game.cardType.x
				elif last.type==Game.cardType.x:	
					temp.type=Game.cardType.man
				temp.rect_position.y=last.rect_position.y+boxSize
				vbox.add_child(temp)
	elif currState==Game.state.stop: #停止
		if speed>0:
			speed-=1
			for i in vbox.get_children():
				i.rect_position.y-=speed*delta
		elif speed<5:
			currState=Game.state.finish
			if vbox.get_child_count()>0:
				var node=vbox.get_child(0)
				var yPos=0
				var idx=0
				if node.rect_position.y<-boxSize/2:  #如果第一个位置超过屏幕外就继续让它滚动到 屏幕外
					yPos=-boxSize
				for i in vbox.get_children():
					var temp=create_tween()
					temp.tween_property(i,'rect_position:y',yPos+boxSize*idx,1)
					if idx==0:
						temp.tween_callback(self,'getResult')
					idx+=1
					
			
		if vbox.get_child_count()>0:
			var node=vbox.get_child(0)
			if node.rect_position.y<-boxSize:	#如果超过了屏幕就往地下增加一个
				vbox.remove_child(node)
				var last=vbox.get_child(vbox.get_child_count()-1) #最后一个
				var temp=card.instance()
				if last.type==Game.cardType.man:	
					temp.type=Game.cardType.s
				elif last.type==Game.cardType.s:
					temp.type=Game.cardType.n
				elif last.type==Game.cardType.n:
					temp.type=Game.cardType.o
				elif last.type==Game.cardType.o:	
					temp.type=Game.cardType.w
				elif last.type==Game.cardType.w:
					temp.type=Game.cardType.x
				elif last.type==Game.cardType.x:	
					temp.type=Game.cardType.man
				temp.rect_position.y=last.rect_position.y+boxSize
				vbox.add_child(temp)
	elif currState==Game.state.finish: #结束
		pass
		
			
func getResult():
	if vbox.get_child_count()>0:
		var node=vbox.get_child(0)
		if node.rect_position.y<0:  #把这个超过屏幕的删除了
			vbox.remove_child(node)
		node=vbox.get_child(0)	
		print(node.type)
		Game.emit_signal("getResult",node.type)
	pass
