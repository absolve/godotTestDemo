extends Sprite


export var time=0.4


func _ready():
	var tween =create_tween().bind_node(self)
#	tween.tween_interval(time)
	tween.tween_property(self,'modulate',Color( 1, 1, 1, 0 ),time)
	tween.tween_callback(self, "queue_free")
	pass


