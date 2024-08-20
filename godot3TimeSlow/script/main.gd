extends Node2D

const size=32
var width
var height
var mapWidth
var mapHeight

var tile=preload("res://scene/tile.tscn")
onready var player=$tank

func _ready():
	VisualServer.set_default_clear_color(Color('#000'))
	OS.center_window()
	
	loadMap("res://level/test0.json")
	width=get_viewport_rect().size.x
	height=get_viewport_rect().size.y
#	Engine.time_scale=0.1
#	AudioServer.global_rate_scale=1.5
	
func loadMap(fileName:String):
	var file = File.new()
	if file.file_exists(fileName):
		file.open(fileName, File.READ)
		var content=parse_json(file.get_as_text())
		mapWidth=int(content['mapWidth'])
		mapHeight=int(content['mapHeight'])
		for i in content['data']:
			if i['type'] =='tile':
				var temp=tile.instance()
				temp.position.x=i['x']*size+size/2
				temp.position.y=i['y']*size+size/2
				add_child(temp)

func getPlayer():
	return player


func _on_slow_pressed():
	Engine.time_scale=0.5
	AudioServer.global_rate_scale=1.5


func _on_normal_pressed():
	Engine.time_scale=1
	AudioServer.global_rate_scale=1
