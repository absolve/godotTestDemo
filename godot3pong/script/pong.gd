extends Node2D

var test=preload("res://scene/testSprite.tscn")
onready var player2=$paddle2
onready var p1ScoreLabel=$p1Score
onready var p2ScoreLabel=$p2Score
var p1Score=0
var p2Score=0


func _ready():
	if get_multiplayer().has_network_peer():
		Game.isOnline=true
		print(is_network_master())
		print("Unique id: ", get_tree().get_network_unique_id())
		if is_network_master():
			player2.set_network_master(get_tree().get_network_connected_peers()[0])
		else:
			player2.set_network_master(get_tree().get_network_unique_id())


remotesync func addTest():
	var temp=test.instance()
	temp.position=Vector2(randi()%100,randi()%100)
	add_child(temp)


#添加分数
remotesync func addScore(p1):
	if p1:
		p1Score+=1
		p1ScoreLabel=str(p1Score)
	else:
		p2Score+=1
		p2ScoreLabel=str(p1Score)



func _on_Button_pressed():
#	addTest()
	rpc('addTest')
