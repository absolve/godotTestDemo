tool
extends Line2D


export var maxPoints=50
export var target_path: NodePath
export var offset:Vector2=Vector2.ZERO 
var startAdd=false 
var timer=0  #添加点的定时器
var delay=20 #毫秒
var lifeTimer=0
var lifetime=50
var angle=0  #角度


onready var target: Node2D = get_node_or_null(target_path)

func _ready():
#	if Engine.editor_hint:
#		set_process(false)
#		return
	clear_points()
	set_as_toplevel(true)


func _process(delta):
	if Engine.editor_hint:
		return
	lifeTimer+=1
	if lifeTimer>lifetime:
		lifeTimer=0
		if get_point_count()>0:
			remove_point(0)
	
	if !startAdd:
		return
	timer+=1
	
	if delay<timer:
		timer=0
		if get_point_count()>maxPoints:
			remove_point(0)
#		print(to_local(target.global_position))		
		add_point(to_local(target.global_position)+offset.rotated(deg2rad(angle)))
		
					
func _get_configuration_warning():
	var warning='Missing Target node'
	if target:
		warning=''
	return warning
