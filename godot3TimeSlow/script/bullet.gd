extends KinematicBody2D


var velocity = Vector2.ZERO



func _physics_process(delta):	
	var collision =move_and_collide(velocity*delta)
	if collision:
		queue_free()
		if collision.collider.has_method('hit'):
			collision.collider.hit()
