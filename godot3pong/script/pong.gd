extends Node2D

var test=preload("res://scene/testSprite.tscn")
onready var player2=$paddle2

func _ready():
	if get_multiplayer().has_network_peer():
		Game.isOnline=true
		print(is_network_master())
		print("Unique id: ", get_tree().get_network_unique_id())
		if is_network_master():
			player2.set_network_master(get_tree().get_network_connected_peers()[0])
		else:
			player2.set_network_master(get_tree().get_network_unique_id())

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
remotesync func addTest():
	var temp=test.instance()
	temp.position=Vector2(randi()%100,randi()%100)
	add_child(temp)

func _on_Button_pressed():
#	addTest()
	rpc('addTest')
