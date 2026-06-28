extends Node

# 敌人状态枚举
# move: 正常流场寻路状态
# findDir: 自主寻路状态（流场方向被阻挡时使用）
# stop: 停止状态
enum enemyState {move, findDir, stop}