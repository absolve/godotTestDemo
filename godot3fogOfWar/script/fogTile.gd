extends Area2D

onready var sprite=$Sprite
#onready var timer=$Timer
onready var shape=$shape
onready var player=$player

var count=8
var status='fog_idle'

func remove():
#	shape.disabled=true
	status='fog_remove'
	player.play("idle")

	

func destroy():
	status='fog_remove'
	player.play("destroy")
	
func _on_Area2D_area_entered(area):
	if status=='fog_idle':
		remove()
	
	
