extends HBoxContainer

@export var enable=false

@onready var volumeBarLeft=$VBoxContainer/VolumeBarLeft
@onready var volumeBarRight=$VBoxContainer2/VolumeBarRight

var left_db 
var right_db 

func _process(_delta: float) -> void:
	if !enable:
		return
	left_db=AudioServer.get_bus_peak_volume_left_db(0,0)
	right_db=AudioServer.get_bus_peak_volume_right_db(0,0)
	
	volumeBarLeft.value=remap(left_db, -60.0, 0.0, 0.0, 100.0)
	volumeBarRight.value=remap(right_db, -60.0, 0.0, 0.0, 100.0)
