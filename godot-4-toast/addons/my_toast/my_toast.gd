@tool
extends EditorPlugin

var scriptName="myToast"

func _enable_plugin():
	# Add autoloads here.
	add_autoload_singleton(scriptName,"res://addons/my_toast/script/myToastAutoload.gd")


func _disable_plugin():
	# Remove autoloads here.
	remove_autoload_singleton(scriptName)


func _enter_tree():
	# Initialization of the plugin goes here.
	pass


func _exit_tree():
	# Clean-up of the plugin goes here.
	pass
