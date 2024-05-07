extends Node2D

var fogTile=preload("res://scene/fogTile.tscn")
const size=32

export var height:float=0
export var width:float=0


func addFogTile():
	for i in range(int(width/size)):
		for y in range(int(height/size)):
			var temp=fogTile.instance()
			temp.position=Vector2(i*size,y*size)+Vector2(size/2,size/2)
			add_child(temp)
			
func clear():
	for i in get_children():
		i.queue_free()
