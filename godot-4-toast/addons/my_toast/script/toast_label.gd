extends Label


signal  remove

var displayTime=2 #显示 秒
var str:String:  #字符串
	set(value):
		str=value
		text=str(value)
var dir="bottom"  #top bottom
var screenSize:Rect2
var margin={'top':20,'bottom':30,'left':20,'right':20}
		
func _ready():
	screenSize=get_viewport_rect()
	init()
	#print(screenSize)
	
func init():
	if dir=='bottom':
		position=Vector2(screenSize.size.x/2-size.x/2,screenSize.size.y-size.y-margin.bottom/2)
	elif dir=="top":
		position=Vector2(screenSize.size.x/2-size.x/2,size.y+margin.top/2)
	
	var tween=create_tween()
	tween.tween_property(self,"modulate:a", 0, 0)
	tween.tween_property(self,"modulate:a", 1, 0.5)
	tween.tween_property(self,"modulate:a", 0, 1).set_delay(displayTime)
	tween.tween_callback(removeLabel)

func movePos(index):
	var tween=create_tween()
	var offsetY=0
	if dir=='bottom':
		offsetY=screenSize.size.y-(size.y+margin.bottom/2)*(index+1)
		tween.tween_property(self, "position",Vector2(position.x,offsetY),0.4)	
		tween.set_trans(Tween.TRANS_SINE)
	elif dir=='top':
		offsetY=(size.y+margin.top/2)*(index+1)
		tween.tween_property(self, "position",Vector2(position.x,offsetY),0.4)	
		tween.set_trans(Tween.TRANS_SINE)
	
func removeLabel():
	remove.emit(self)
	queue_free()
