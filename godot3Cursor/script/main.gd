extends Node2D

var tile=preload("res://scene/tile.tscn")
const size=32
var width
var height
var mapWidth
var mapHeight

func _ready():
	
	width=get_viewport_rect().size.x
	height=get_viewport_rect().size.y

	loadMap("res://test0.json")
	
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
#				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*size+size/2
				temp.position.y=i['y']*size+size/2
				add_child(temp)

func _on_Button_pressed():
	set_process_input(false)
	get_tree().change_scene("res://scene/welcome.tscn")
	set_process_input(true)
