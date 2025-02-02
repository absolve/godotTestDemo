extends Node2D

var test=preload("res://scene/testSprite.tscn")
onready var player1=$paddle
onready var player2=$paddle2
onready var p1ScoreLabel=$p1Score
onready var p2ScoreLabel=$p2Score
var p1Score=0
var p2Score=0


func _ready():
	if get_multiplayer().has_network_peer():
		Game.isOnline=true
		print('get_network_master',get_network_master())
		print('is_network_master ',is_network_master())
		print("Unique id: ", get_tree().get_network_unique_id())
		if is_network_master():
			player1.showLable()
			player2.set_network_master(get_tree().get_network_connected_peers()[0])
		else:
			player2.showLable()
			player2.set_network_master(get_tree().get_network_unique_id())
	Game.connect("update_score",self,'updateScore')


#添加分数
remotesync func addScore(p1):
	print('addScore',multiplayer.get_rpc_sender_id())
	if p1:
		p1Score+=1
		p1ScoreLabel.text=str(p1Score)
	else:
		p2Score+=1
		p2ScoreLabel.text=str(p2Score)

#更新分数
func updateScore(pos):
#	print('updateScore')
	if pos<0:
		rpc('addScore',false)
	else:
		rpc('addScore',true)	


master func addTest():
	var temp=test.instance()
	temp.position=Vector2(randi()%100,randi()%100)
	add_child(temp)

func _on_Button_pressed():
#	addTest()
	rpc('addTest')
