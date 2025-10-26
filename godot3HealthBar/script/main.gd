extends Node2D


onready var healthBar=$healthBar


func _ready():
	OS.center_window()
	


func _on_Button_pressed():
	healthBar.emit_signal("update_health",healthBar.value+30)
	

func _on_sub_pressed():
	healthBar.emit_signal("update_health",healthBar.value-30)
