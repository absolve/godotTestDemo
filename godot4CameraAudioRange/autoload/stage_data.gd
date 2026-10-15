extends Node

## 只保留 `prop.gd` 需要的那一个常量。
##
## 原项目里 StageData 是个 1100 行的关卡表（依赖 Game 的枚举），演示项目用不到。
## 但 `script/level/prop.gd` 里写了 `StageData.TileSize`，装饰物对齐格子时会读它，
## 所以这里留一个**最小替身**，就能让 prop.gd 原样不改地跑起来。

const TileSize: int = 64
