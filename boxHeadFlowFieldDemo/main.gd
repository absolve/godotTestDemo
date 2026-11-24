extends Node2D

const GRID_SIZE := Vector2i(24, 16)
const CELL_SIZE := 32
const BOARD_ORIGIN := Vector2(32, 112)
const BOARD_SIZE := Vector2(GRID_SIZE.x * CELL_SIZE, GRID_SIZE.y * CELL_SIZE)
const MOVE_SPEED := 80.0
const UNCLAIMED := Vector2i(-9999, -9999)
const ENEMY_SCENE: PackedScene = preload("res://enemy.tscn")
const NEIGHBORS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1),
]

@onready var player_actor: Node2D = $Actors/Player
@onready var enemy_layer: Node2D = $Actors/Enemies

var font: Font
var target_cell := Vector2i(21, 8)
var obstacles: Dictionary = {}
var distance_field: Dictionary = {}
var flow_field: Dictionary = {}
var occupied_cells: Dictionary = {}
var reserved_cells: Dictionary = {}
var enemies: Array[Dictionary] = []
var paused := false
var show_flow := true


func _ready() -> void:
	font = ThemeDB.fallback_font
	_reset_demo()


func _physics_process(delta: float) -> void:
	if not paused:
		for i in range(enemies.size()):
			var enemy: Dictionary = enemies[i]
			if enemy["moving"]:
				enemy["progress"] = minf(
					float(enemy["progress"]) + delta / float(enemy["travel_time"]), 1.0
				)
				if float(enemy["progress"]) >= 1.0:
					_finish_move(i)
			else:
				_start_move(i)
			_sync_enemy_actor(enemy)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var cell := _mouse_to_cell(event.position)
		if not _is_inside(cell):
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not obstacles.has(cell):
				target_cell = cell
				player_actor.position = _world_position_at_cell_position(Vector2(cell))
				_rebuild_fields()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if cell != target_cell and not occupied_cells.has(cell) \
					and not reserved_cells.has(cell):
				if obstacles.has(cell):
					obstacles.erase(cell)
				else:
					obstacles[cell] = true
				_rebuild_fields()
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE:
				paused = not paused
			KEY_F:
				show_flow = not show_flow
			KEY_R:
				_reset_demo()
	queue_redraw()


func _reset_demo() -> void:
	target_cell = Vector2i(21, 8)
	player_actor.position = _world_position_at_cell_position(Vector2(target_cell))
	obstacles.clear()
	for y in range(GRID_SIZE.y):
		if y != 8:
			obstacles[Vector2i(12, y)] = true
	for cell in [
		Vector2i(8, 4), Vector2i(8, 5), Vector2i(8, 6),
		Vector2i(8, 10), Vector2i(8, 11),
		Vector2i(17, 5), Vector2i(17, 6), Vector2i(17, 7),
		Vector2i(17, 9), Vector2i(17, 10), Vector2i(17, 11),
	]:
		obstacles[cell] = true

	for actor in enemy_layer.get_children():
		actor.queue_free()
	enemies.clear()
	occupied_cells.clear()
	reserved_cells.clear()
	var starts: Array[Vector2i] = [
		Vector2i(2, 2), Vector2i(2, 4), Vector2i(2, 6), Vector2i(2, 8),
		Vector2i(2, 10), Vector2i(2, 12), Vector2i(4, 3), Vector2i(4, 5),
		Vector2i(4, 7), Vector2i(4, 9), Vector2i(4, 11), Vector2i(4, 13),
	]
	for i in range(starts.size()):
		var cell: Vector2i = starts[i]
		var actor := ENEMY_SCENE.instantiate() as Node2D
		enemy_layer.add_child(actor)
		enemies.append({
			"cell": cell,
			"from": cell,
			"to": cell,
			"progress": 0.0,
			"travel_time": 1.0,
			"moving": false,
			"actor": actor,
		})
		_sync_enemy_actor(enemies[i])
		occupied_cells[cell] = i
		reserved_cells[cell] = i
	paused = false
	show_flow = true
	_rebuild_fields()


func _rebuild_fields() -> void:
	distance_field.clear()
	flow_field.clear()

	var queue: Array[Vector2i] = [target_cell]
	distance_field[target_cell] = 0
	var head := 0
	while head < queue.size():
		var current: Vector2i = queue[head]
		head += 1
		var current_distance: int = distance_field[current]
		for step in NEIGHBORS:
			var next := current + step
			if not _is_inside(next) or obstacles.has(next) or distance_field.has(next):
				continue
			if _cuts_obstacle_corner(current, step):
				continue
			var step_cost := 1414 if step.x != 0 and step.y != 0 else 1000
			distance_field[next] = current_distance + step_cost
			queue.append(next)

	for x in range(GRID_SIZE.x):
		for y in range(GRID_SIZE.y):
			var cell := Vector2i(x, y)
			if obstacles.has(cell) or not distance_field.has(cell):
				flow_field[cell] = Vector2.ZERO
				continue
			if int(distance_field[cell]) == 0:
				flow_field[cell] = Vector2.ZERO
				continue
			var best_step := Vector2i.ZERO
			var best_distance := INF
			for step in NEIGHBORS:
				var next := cell + step
				if distance_field.has(next) and float(distance_field[next]) < best_distance:
					best_distance = float(distance_field[next])
					best_step = step
			flow_field[cell] = Vector2(best_step).normalized()


func _start_move(enemy_id: int) -> void:
	var enemy: Dictionary = enemies[enemy_id]
	var cell: Vector2i = enemy["cell"]
	if not distance_field.has(cell) or int(distance_field[cell]) == 0 \
			or maxi(absi(cell.x - target_cell.x), absi(cell.y - target_cell.y)) <= 1:
		return

	var wanted: Vector2 = flow_field.get(cell, Vector2.ZERO)
	var best_cell := UNCLAIMED
	var best_distance := INF
	var best_alignment := -INF
	for step in NEIGHBORS:
		var next := cell + step
		if not _is_inside(next) or obstacles.has(next):
			continue
		if _cuts_obstacle_corner(cell, step):
			continue
		if next == target_cell or occupied_cells.has(next):
			continue
		if reserved_cells.has(next) and int(reserved_cells[next]) != enemy_id:
			continue
		if not distance_field.has(next) or int(distance_field[next]) >= int(distance_field[cell]):
			continue

		var next_distance := float(distance_field[next])
		var alignment := Vector2(step).normalized().dot(wanted)
		if next_distance < best_distance \
				or (is_equal_approx(next_distance, best_distance) and alignment > best_alignment):
			best_cell = next
			best_distance = next_distance
			best_alignment = alignment

	if best_cell == UNCLAIMED:
		return

	if reserved_cells.get(cell, -1) == enemy_id:
		reserved_cells.erase(cell)
	reserved_cells[best_cell] = enemy_id
	enemy["from"] = cell
	enemy["to"] = best_cell
	var diagonal := cell.x != best_cell.x and cell.y != best_cell.y
	enemy["travel_time"] = (float(CELL_SIZE) / MOVE_SPEED) * (1.41421356 if diagonal else 1.0)
	enemy["progress"] = 0.0
	enemy["moving"] = true


func _finish_move(enemy_id: int) -> void:
	var enemy: Dictionary = enemies[enemy_id]
	var old_cell: Vector2i = enemy["from"]
	var new_cell: Vector2i = enemy["to"]
	if occupied_cells.get(old_cell, -1) == enemy_id:
		occupied_cells.erase(old_cell)
	occupied_cells[new_cell] = enemy_id
	enemy["cell"] = new_cell
	enemy["from"] = new_cell
	enemy["progress"] = 0.0
	enemy["moving"] = false


func _sync_enemy_actor(enemy: Dictionary) -> void:
	var cell_position: Vector2
	if enemy["moving"]:
		cell_position = Vector2(enemy["from"]).lerp(
				Vector2(enemy["to"]), float(enemy["progress"]))
	else:
		cell_position = Vector2(enemy["cell"])
	var actor: Node2D = enemy["actor"]
	actor.position = _world_position_at_cell_position(cell_position)


func _world_position_at_cell_position(cell_position: Vector2) -> Vector2:
	return BOARD_ORIGIN + (cell_position + Vector2(0.5, 0.5)) * CELL_SIZE


func _cuts_obstacle_corner(cell: Vector2i, step: Vector2i) -> bool:
	if step.x == 0 or step.y == 0:
		return false
	return obstacles.has(cell + Vector2i(step.x, 0)) \
			or obstacles.has(cell + Vector2i(0, step.y))


func _mouse_to_cell(mouse_position: Vector2) -> Vector2i:
	var local := mouse_position - BOARD_ORIGIN
	return Vector2i(floori(local.x / CELL_SIZE), floori(local.y / CELL_SIZE))


func _is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < GRID_SIZE.x and cell.y < GRID_SIZE.y


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1100, 700)), Color("#111722"))
	draw_string(font, Vector2(32, 42), "Box Head | 敌人流场寻路与格子占位",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("#f0f3f8"))
	draw_string(font, Vector2(32, 72),
			"颜色表示到目标的距离；箭头表示每格的流场方向。障碍物会让整张场重新计算。",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#aeb9ca"))

	_draw_board()
	_draw_legend()


func _draw_board() -> void:
	var max_distance := 1.0
	for value in distance_field.values():
		max_distance = maxf(max_distance, float(value))

	for x in range(GRID_SIZE.x):
		for y in range(GRID_SIZE.y):
			var cell := Vector2i(x, y)
			var rect := Rect2(BOARD_ORIGIN + Vector2(x, y) * CELL_SIZE,
					Vector2(CELL_SIZE, CELL_SIZE))
			var fill := Color("#202a38")
			if distance_field.has(cell):
				var closeness := 1.0 - float(distance_field[cell]) / max_distance
				fill = Color("#18364a").lerp(Color("#24645a"), closeness)
			draw_rect(rect, fill)

			if occupied_cells.has(cell):
				draw_rect(rect.grow(-3), Color(0.18, 0.55, 0.88, 0.28))
			if reserved_cells.has(cell) and int(reserved_cells[cell]) >= 0:
				var enemy: Dictionary = enemies[int(reserved_cells[cell])]
				if enemy["moving"] and enemy["to"] == cell:
					draw_rect(rect.grow(-2), Color("#f6c453"), false, 2.0)

			if obstacles.has(cell):
				draw_rect(rect.grow(-2), Color("#566070"))
				draw_line(rect.position + Vector2(5, 5), rect.end - Vector2(5, 5),
						Color("#7c8998"), 2.0)
				draw_line(rect.position + Vector2(CELL_SIZE - 5, 5),
						rect.position + Vector2(5, CELL_SIZE - 5), Color("#7c8998"), 2.0)
			elif show_flow and flow_field.has(cell):
				var direction: Vector2 = flow_field[cell]
				if direction != Vector2.ZERO:
					var center := rect.position + Vector2(CELL_SIZE * 0.5, CELL_SIZE * 0.5)
					var tip := center + direction * 9.0
					draw_line(center - direction * 5.0, tip, Color("#d5f4e8"), 2.0)
					draw_line(tip, tip - direction.rotated(0.65) * 5.0,
							Color("#d5f4e8"), 2.0)
					draw_line(tip, tip - direction.rotated(-0.65) * 5.0,
							Color("#d5f4e8"), 2.0)

			if distance_field.has(cell) and not obstacles.has(cell):
				var steps := str(int(round(float(distance_field[cell]) / 1000.0)))
				draw_string(font, rect.position + Vector2(3, 10), steps,
						HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.9, 0.94, 1.0, 0.65))

			draw_rect(rect, Color(0.75, 0.82, 0.92, 0.17), false, 1.0)

	draw_rect(Rect2(BOARD_ORIGIN, BOARD_SIZE), Color("#aeb9ca"), false, 2.0)


func _draw_legend() -> void:
	var x := 835.0
	var y := 126.0
	draw_string(font, Vector2(x, y), "演示操作", HORIZONTAL_ALIGNMENT_LEFT, -1, 19,
			Color("#f0f3f8"))
	y += 34.0
	var lines: Array[String] = [
		"左键  设置追击目标 / 重算流场",
		"右键  添加或移除障碍",
		"Space 暂停 / 继续",
		"F     显示 / 隐藏箭头",
		"R     重置演示",
	]
	for line in lines:
		draw_string(font, Vector2(x, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, 14,
				Color("#c2ccda"))
		y += 27.0

	y += 10.0
	draw_string(font, Vector2(x, y), "图例", HORIZONTAL_ALIGNMENT_LEFT, -1, 19,
			Color("#f0f3f8"))
	y += 29.0
	draw_rect(Rect2(x, y - 12, 16, 16), Color("#18364a"))
	draw_string(font, Vector2(x + 25, y), "距离远（场的代价较高）",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#c2ccda"))
	y += 25.0
	draw_rect(Rect2(x, y - 12, 16, 16), Color("#24645a"))
	draw_string(font, Vector2(x + 25, y), "距离近（代价较低）",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#c2ccda"))
	y += 25.0
	draw_rect(Rect2(x, y - 12, 16, 16), Color("#566070"))
	draw_string(font, Vector2(x + 25, y), "静态障碍",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#c2ccda"))
	y += 25.0
	draw_rect(Rect2(x, y - 12, 16, 16), Color(0.18, 0.55, 0.88, 0.55))
	draw_string(font, Vector2(x + 25, y), "敌人当前占用格",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#c2ccda"))
	y += 25.0
	draw_rect(Rect2(x, y - 12, 16, 16), Color("#f6c453"), false, 2.0)
	draw_string(font, Vector2(x + 25, y), "敌人下一步预留格",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#c2ccda"))

	y += 45.0
	draw_string(font, Vector2(x, y), "核心逻辑", HORIZONTAL_ALIGNMENT_LEFT, -1, 19,
			Color("#f0f3f8"))
	y += 28.0
	var details: Array[String] = [
		"1. 从目标格做八邻域 BFS，",
		"   得到每格到目标的距离。",
		"2. 每格指向距离更小的邻格，",
		"   汇成共享的流场。",
		"3. 敌人沿流场前进；若目标格",
		"   或下一格已占用 / 预留，则选",
		"   更近的可通行格，在目标边停下。",
		"4. 对角移动不能切过墙角。",
	]
	for line in details:
		draw_string(font, Vector2(x, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, 13,
				Color("#aeb9ca"))
		y += 21.0

	var reached := 0
	for value in distance_field.values():
		if int(value) >= 0:
			reached += 1
	draw_string(font, Vector2(x, 615), "可达格：%d / %d" % [reached, GRID_SIZE.x * GRID_SIZE.y],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#7ee0b6"))
	draw_string(font, Vector2(x, 644), "状态：%s" % ("已暂停" if paused else "运行中"),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14,
			Color("#f6c453") if paused else Color("#7ee0b6"))
