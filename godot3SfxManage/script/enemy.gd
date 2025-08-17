extends "res://script/tank.gd"



var objType=Game.objType.ENEMY
var explode=preload("res://scene/explosion.tscn")



func addExplosion():
	var temp=explode.instance()
	temp.big=true
	temp.position=position
	temp.playSound=true
	temp.isEnemy=true
	Game.addObj(temp)

func _on_tank_area_entered(area):
	if area.get('objType')==Game.objType.BULLET:
		set_deferred('monitorable',false)
		set_deferred('monitoring',false)
		addExplosion()
		call_deferred('queue_free')	
