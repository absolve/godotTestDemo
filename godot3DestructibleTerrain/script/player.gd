extends RigidBody2D

onready var canon=$canon
onready var sprite=$Sprite
onready var shape=$CollisionPolygon2D
 
var speed = 500  #速度
var jumpSpeed=400  #跳跃速度

func _ready():
	var image = sprite.texture.get_data()
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image, 0.01)
	var bitmap_rect = Rect2(Vector2(0, 0), bitmap.get_size())
	var polygons = bitmap.opaque_to_polygons(bitmap_rect, 0) 
	shape.polygon=Transform2D(0,-bitmap.get_size()/2).xform(polygons[0])
	

func _physics_process(delta):
	canon.look_at(get_global_mouse_position())
	
	if Input.is_action_pressed("left"):
		apply_central_impulse(-global_transform.x * speed * delta)
	elif Input.is_action_pressed("right"):
		apply_central_impulse(global_transform.x * speed * delta)
	elif Input.is_action_just_pressed("jump"):
		apply_central_impulse(Vector2.UP * jumpSpeed)

