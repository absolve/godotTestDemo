extends Node2D

onready var panel=$panel
onready var address=$panel/Panel/VBoxContainer/LineEdit
onready var status=$panel/Panel/VBoxContainer/status
const DEFAULT_PORT = 9999

var peer
var pong=preload("res://scene/pong.tscn")


func _ready():
	VisualServer.set_default_clear_color('#000')
	OS.center_window()
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


func setStatus(msg):
	status.text=str(msg)
	
	pass

func _player_connected(id):
	print('_player_connected ',id)
	panel.hide()
	var temp=pong.instance()
	add_child(temp)
	pass

func _player_disconnected(id):
	print('_player_disconnected ',id)
	if get_tree().is_network_server():  #自身是服务器
		print('Client disconnected')
	else:
		
		print('Server disconnected')

func _connected_ok():
	print('_connected_ok')


func _connected_fail():
	setStatus('connected fail')
	print('_connected_fail')

func _server_disconnected():
	print('_server_disconnected')


func _on_btnHost_pressed():
	peer = NetworkedMultiplayerENet.new()
	peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	var err = peer.create_server(DEFAULT_PORT)
	if err!=OK:
		setStatus("Can't host, address in use.")
		return
	get_tree().set_network_peer(peer)
	setStatus("Connecting...")
		
	


func _on_btnJoin_pressed():
	var ip = address.get_text()
	print(ip)
	if not ip.is_valid_ip_address():
		setStatus("IP address is invalid")
		return
	peer = NetworkedMultiplayerENet.new()	
	peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)
