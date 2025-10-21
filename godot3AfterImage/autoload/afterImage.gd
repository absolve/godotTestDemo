extends Node2D



var img=preload("res://scene/image.tscn")



#添加图片
func addImage(texture,pos:Vector2):
	var temp=img.instance()
	temp.position=pos
	add_child(temp)

