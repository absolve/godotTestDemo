extends Label


signal  remove

var displayTime=2 #2 秒
var str:String:  #字符串
	set(value):
		str=value
		text=str(value)
var dir="bottom"  #top bottom
		
func _ready():
	init()
	pass

func init():
	if dir=='bottom':
		
		pass
	elif dir=="top":
		
		pass
	
	var tween=create_tween()
	tween.tween_property(self,"modulate:a", 0, 0)
	tween.tween_property(self,"modulate:a", 1, 0.5)
	tween.tween_property(self,"modulate:a", 0, 1).set_delay(displayTime)
	tween.tween_callback(removeLabel)

func movePos():
	
	pass

func removeLabel():
	remove.emit(self)
	queue_free()
