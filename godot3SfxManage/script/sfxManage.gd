extends Node

var sfx=preload("res://scene/sfx.tscn")


var explosion1=preload("res://sound/explosion_1.ogg")
var explosion2=preload("res://sound/explosion_2.ogg")

func _ready():
	pass # Replace with function body.

#播放声音
func playSfx(res,bus:String):
	var temp=sfx.instance()
	temp.stream=res
	temp.bus=bus
	add_child(temp)


func playExplosion():
	playSfx(explosion1,"Sfx")

func playBigExplosion():
	playSfx(explosion2,"Sfx")


