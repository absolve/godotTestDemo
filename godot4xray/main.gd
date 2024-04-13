extends Node2D

@onready var light=$PointLight2D


func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var tween = create_tween()
	tween.tween_property(light, "position",
		get_global_mouse_position(), 1)
