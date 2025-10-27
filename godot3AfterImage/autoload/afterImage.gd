extends Node2D



var img=preload("res://scene/image.tscn")
var grayShader=preload("res://shader/gray_shader.tres")
var blackShader=preload("res://shader/black_shader.tres")
var blueShader=preload("res://shader/blue_shader.tres")
var replaceShader=preload("res://shader/replace_shader.tres")

#添加图片
func addImage(texture,pos:Vector2,scale=Vector2(1,1),flipH=false,flipV=false):
	var temp=img.instance()
	temp.texture=texture
	temp.position=pos
	temp.scale=scale
	temp.material=grayShader
#	temp.modulate.a=0.5
	temp.flip_h=flipH
	temp.flip_v=flipV
	add_child(temp)

#黑色图片
func addBlackImage(texture,pos:Vector2,scale=Vector2(1,1),flipH=false,flipV=false):
	var temp=img.instance()
	temp.texture=texture
	temp.position=pos
	temp.scale=scale
	temp.material=blackShader
	temp.flip_h=flipH
	temp.flip_v=flipV
	temp.modulate.a=0.5
	add_child(temp)


func addBlueImage(texture,pos:Vector2,scale=Vector2(1,1),flipH=false,flipV=false):
	var temp=img.instance()
	temp.texture=texture
	temp.position=pos
	temp.scale=scale
	temp.material=blueShader
	temp.flip_h=flipH
	temp.flip_v=flipV
	temp.modulate.a=0.5
	temp.z_index=1
#	temp.time=1
	add_child(temp)
	
	
func addSkeletonImage(texture,pos:Vector2,scale=Vector2(1,1),flipH=false,flipV=false):
	var temp=img.instance()
	temp.texture=texture
	temp.position=pos
	temp.scale=scale
	temp.material=replaceShader
	temp.flip_h=flipH
	temp.flip_v=flipV
#	temp.modulate.a=0.5
#	temp.time=1
	temp.z_index=1
	add_child(temp)
	
	
