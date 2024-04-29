extends Line2D


var segments=12

onready var ray=$RayCast2D
onready var player=$player

func _ready():
	set_as_toplevel(true)
	player.play("start")
	

func add(start: Vector2, end: Vector2):
	ray.global_position=start
	ray.cast_to=end - start
	ray.force_raycast_update()
	
	if ray.is_colliding():
		end = ray.get_collision_point()
		
	var point=[]
	var length=start.distance_to(end) / segments
	var currpos=start
	point.append(start)
	
	for i in segments:
		var newpos=currpos+(currpos.direction_to(end)*length).rotated(rand_range(-0.5, 0.5))
		point.append(newpos)
		currpos=newpos
	point.append(end)	
	points=point
	
	
