extends KinematicBody2D

var velocity=Vector2.ZERO	#速度
var angularVel=5
var speed=200	#移动速度
var rayCount=36 #射线数量
var ray_directions = []
var rayLength=80  #射线长度

onready var barrel=$barrel
onready var ani=$ani
onready var area=$Area2D


export var useArea:bool=true

class RayDirections:
	var rayLength=0
	var dir=Vector2.ZERO
#	var canMove=false
	
	func _init(length : float, dir : Vector2):
		self.rayLength=length
		self.dir=dir

func _ready():
	if useArea:
		area.monitorable=true
	else:
		area.monitorable=false	

	for i in range(0, rayCount):
		var ray=RayDirections.new(rayLength,Vector2.RIGHT.rotated(i * PI * 2 / rayCount))
		ray_directions.append(ray)


func _physics_process(delta):
	
	barrel.look_at(get_global_mouse_position())
	velocity=Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		velocity.x=-speed
	if Input.is_action_pressed("ui_right"):
		velocity.x=speed
	if Input.is_action_pressed("ui_up"):
		velocity.y=-speed
	if Input.is_action_pressed("ui_down"):
		velocity.y=speed

	
	if !useArea:
		var space_state = get_world_2d().direct_space_state
		for i in ray_directions:
			var result=space_state.intersect_ray(global_position,
			global_position+i.dir*i.rayLength,[self],collision_mask+4,false,true)
			if result:
#				print(result)
				if result.collider is Area2D:
					if result.collider.status=='fog_idle':
#						print(result)
						result.collider.destroy()
						
	move_and_collide(velocity*delta)					
	animation()

	
func animation():
	if velocity!=Vector2.ZERO:
		var angle=round(rad2deg(velocity.angle()))
		if angle<0:
			angle=360-abs(angle)
		if 	abs(angle-ani.rotation_degrees)>180:#变化的幅度超过180 就把angle增加360或者较少360
			if angle<ani.rotation_degrees:
				angle+=360
			else:
				angle-=360
		
		if ani.rotation_degrees!=angle:
			if ani.rotation_degrees>angle:
				if ani.rotation_degrees-angularVel<angle:
					ani.rotation_degrees=angle
				else:
					ani.rotation_degrees-=angularVel
			if ani.rotation_degrees<angle:		
				if ani.rotation_degrees+angularVel>angle:
					ani.rotation_degrees=angle
				else:
					ani.rotation_degrees+=angularVel		
		ani.play("default")
	else:
		ani.stop()
	
func _draw():
	if !useArea:
		for i in ray_directions:
			draw_line(Vector2.ZERO, (i.dir*i.rayLength) , Color(1.0, .329, .298))
