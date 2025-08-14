extends AudioStreamPlayer






func _ready():
	connect("finished",self,'destroy')
	if stream !=null:
		play()

func  destroy():
	queue_free()
