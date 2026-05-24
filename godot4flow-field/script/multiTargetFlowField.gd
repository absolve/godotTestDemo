extends Node

var mapSize:Vector2=Vector2(32,24)
var cellSize:Vector2=Vector2(32,32)


#目标点距离   key 为x-y  value为距离
var distanceField:Dictionary={}
#流场 指向最近目标的方向向量 key 为x-y value为方向
var flowField:Dictionary={}
#障碍物 key 为x-y value为方向
var obstacle:Dictionary={}
