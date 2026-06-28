extends Node

# 地图尺寸（格子数），32列 x 24行
var mapSize: Vector2 = Vector2(32, 24)
# 每个格子的像素大小，32x32像素
var cellSize: Vector2 = Vector2(32, 32)


# 距离场：记录每个格子到最近目标点的距离
# key格式为"x-y"，value为距离值
var distanceField: Dictionary = {}
# 流场：记录每个格子指向最近目标的方向向量
# key格式为"x-y"，value为方向向量（8方向之一）
var flowField: Dictionary = {}
# 障碍物集合：记录所有障碍物位置
# key格式为"x-y"，value为障碍物格子坐标
var obstacle: Dictionary = {}