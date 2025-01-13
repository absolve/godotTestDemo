extends Node2D





func _ready():
	print(is_network_master())
	print("Unique id: ", get_tree().get_network_unique_id())



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
