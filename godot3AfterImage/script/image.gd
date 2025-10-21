extends Sprite


export var time=0.5


func _ready():
	create_tween().bind_node(self).tween_interval(time).tween_callback(self, "queue_free")



