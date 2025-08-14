extends AnimatedSprite

var big=false #是否是大爆炸

func _ready():
	if big:
		play("big")
		SfxManage.playBigExplosion()
	else:
		play("default")
		SfxManage.playExplosion()
	
	yield(self,"animation_finished")
	queue_free()
