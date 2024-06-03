extends AnimatedSprite






func _ready():
	
	pass # Replace with function body.

func _enter_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	position=get_global_mouse_position()
	
