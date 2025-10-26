extends CenterContainer


export var value:int = 100
export var maxValue=100

onready var fgProgress=$fgProgress
onready var bgProgress=$bgProgress

signal update_health(amount)
var tween

func _ready():
	connect("update_health", self, "_on_update_health")

func _on_update_health(value):
	if value>maxValue :
		value=maxValue
	if value<0:
		value=0
	
	if tween:
		tween.kill()
	tween = create_tween()
	
	if value<=self.value:
		tween.parallel().tween_property(fgProgress, "value", value, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(bgProgress, "value", value, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	else:
		tween.parallel().tween_property(fgProgress, "value", value, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(bgProgress, "value", value, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	self.value=value	


	
	

