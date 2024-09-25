extends TextureRect



export var type=Game.cardType.man


var img1=preload("res://sprite/NES - Snow Brothers Snow Bros Nick & Tom - Machine Bonus_33.png")
var img2=preload("res://sprite/NES - Snow Brothers Snow Bros Nick & Tom - Machine Bonus_34.png")
var img3=preload("res://sprite/NES - Snow Brothers Snow Bros Nick & Tom - Machine Bonus_29.png")
var img4=preload("res://sprite/NES - Snow Brothers Snow Bros Nick & Tom - Machine Bonus_30.png")
var img5=preload("res://sprite/NES - Snow Brothers Snow Bros Nick & Tom - Machine Bonus_32.png")
var img6=preload("res://sprite/NES - Snow Brothers Snow Bros Nick & Tom - Machine Bonus_31.png")



func _ready():
	if type==Game.cardType.man:
		texture=img5
	elif type==Game.cardType.s:
		texture=img1
	elif type==Game.cardType.n:
		texture=img2
	elif type==	Game.cardType.o:
		texture=img3
	elif type==Game.cardType.w:
		texture=img4
	elif type==Game.cardType.x:
		texture=img6

