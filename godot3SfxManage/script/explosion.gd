extends AnimatedSprite

var big=false #是否是大爆炸
var playSound=false
var isEnemy=true

func _ready():
	if big:
		play("big")	
	else:
		play("default")
		
		
	if playSound:
		if isEnemy:
			SfxManage.playExplosion()
		else:
			SfxManage.playBigExplosion()			
	yield(self,"animation_finished")
	queue_free()
