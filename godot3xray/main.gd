extends Node2D


onready var light=$Light2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	var tween = create_tween()
	tween.tween_property(light, "position",
		get_global_mouse_position(), 1)
	
