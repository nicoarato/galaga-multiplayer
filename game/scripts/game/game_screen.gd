extends Control
class_name GameScreen

signal local_player_position_changed(position: Vector2)
signal local_player_shot(shot_position: Vector2, damage: float, projectile_range: float)
signal local_enemy_destroyed(enemy_id: String)
signal local_player_hit(player_id: String, damage: float)

const POSITION_SEND_INTERVAL := 0.05
const ENEMY_COLUMNS := 6
const ENEMY_ROWS := 2
const ENEMY_SPACING := Vector2(108, 62)
const ENEMY_SPEED := 64.0
const ENEMY_SHOT_INTERVAL := 2.5
const ENEMY_PROJECTILE_DAMAGE := 12.0
const ENEMY_TYPE_ORDER := [
	"drone",
	"zigzag",
	"tank",
	"sprinter",
	"shooter",
	"splitter",
	"shield",
	"diver",
	"support",
	"elite",
	"drone",
	"sprinter",
]
const ENEMY_TYPES := {
	"drone": {"health": 36.0, "scale": 0.85, "color": Color(0.1, 0.94, 1.0, 1.0)},
	"zigzag": {"health": 44.0, "scale": 0.95, "color": Color(1.0, 0.28, 0.72, 1.0)},
	"tank": {"health": 80.0, "scale": 1.25, "color": Color(0.86, 1.0, 0.18, 1.0)},
	"sprinter": {"health": 28.0, "scale": 0.75, "color": Color(1.0, 0.65, 0.12, 1.0)},
	"shooter": {"health": 52.0, "scale": 1.0, "color": Color(0.72, 0.4, 1.0, 1.0)},
	"splitter": {"health": 48.0, "scale": 1.05, "color": Color(0.2, 1.0, 0.62, 1.0)},
	"shield": {"health": 72.0, "scale": 1.2, "color": Color(0.25, 0.58, 1.0, 1.0)},
	"diver": {"health": 40.0, "scale": 0.9, "color": Color(1.0, 0.34, 0.22, 1.0)},
	"support": {"health": 46.0, "scale": 1.0, "color": Color(0.24, 1.0, 0.9, 1.0)},
	"elite": {"health": 96.0, "scale": 1.3, "color": Color(1.0, 0.82, 0.2, 1.0)},
}
const PLAY_AREA_HORIZONTAL_MARGIN := 96.0
const PLAY_AREA_TOP_MARGIN := 32.0
const PLAY_AREA_BOTTOM_MARGIN := 56.0
const SHIP_BOTTOM_OFFSET := 32.0
const SHIP_CLASSES := [
	{
		"name": "Scout",
		"max_health": 80.0,
		"damage": 18.0,
		"projectile_range": 440.0,
	},
	{
		"name": "Fighter",
		"max_health": 100.0,
		"damage": 24.0,
		"projectile_range": 520.0,
	},
	{
		"name": "Tank",
		"max_health": 140.0,
		"damage": 16.0,
		"projectile_range": 680.0,
	},
	{
		"name": "Striker",
		"max_health": 90.0,
		"damage": 32.0,
		"projectile_range": 400.0,
	},
]

@export var player_ship_scene: PackedScene
@export var projectile_scene: PackedScene
@export var enemy_scene: PackedScene
@export var enemy_projectile_scene: PackedScene

@onready var room_id_label: Label = %RoomIdLabel
@onready var status_label: Label = %StatusLabel
@onready var health_hud: HBoxContainer = %HealthHud
@onready var players_list: VBoxContainer = %PlayersList
@onready var playfield: Control = %Playfield
@onready var ships_layer: Node2D = %ShipsLayer
@onready var enemies_layer: Node2D = %EnemiesLayer
@onready var projectiles_layer: Node2D = %ProjectilesLayer
@onready var enemy_projectiles_layer: Node2D = %EnemyProjectilesLayer

var _local_player_id := ""
var _current_players: Array = []
var _ships_by_player_id := {}
var _pending_local_position := Vector2.ZERO
var _has_pending_local_position := false
var _position_send_elapsed := 0.0
var _enemy_wave_spawned := false
var _enemy_direction := 1.0
var _enemies_by_id := {}
var _health_by_player_id := {}
var _health_rows_by_player_id := {}
var _health_hud_signature := ""
var _enemy_shot_elapsed := 0.0
var _enemy_shot_index := 0
var _enemy_wave_elapsed := 0.0


func _process(delta: float) -> void:
	_process_enemy_wave(delta)
	_process_enemy_patterns(delta)
	_process_enemy_attacks(delta)

	if not _has_pending_local_position:
		return

	_position_send_elapsed += delta

	if _position_send_elapsed < POSITION_SEND_INTERVAL:
		return

	_position_send_elapsed = 0.0
	_has_pending_local_position = false
	local_player_position_changed.emit(_pending_local_position)


func set_room(room: Dictionary, local_player_id := "") -> void:
	var room_id := str(room.get("id", ""))
	var status := str(room.get("status", "in_game"))
	var players: Array = room.get("players", [])

	if not local_player_id.is_empty():
		_local_player_id = local_player_id

	room_id_label.text = "ROOM %s" % room_id
	status_label.text = "Status: %s" % status.to_upper()
	_render_players(players)
	_current_players = players
	_sync_player_health(players)
	_render_health_hud(players)
	_schedule_sync_ships()
	_schedule_spawn_enemy_wave()


func _render_players(players: Array) -> void:
	for child in players_list.get_children():
		child.queue_free()

	for player in players:
		if typeof(player) == TYPE_DICTIONARY:
			players_list.add_child(_player_row(player as Dictionary))


func _player_row(player: Dictionary) -> Label:
	var player_name := str(player.get("name", "Player"))
	var row := Label.new()
	row.add_theme_color_override("font_color", Color(0.0862745, 0.941176, 1, 1))
	row.add_theme_font_size_override("font_size", 24)
	row.text = player_name
	return row


func _sync_ships() -> void:
	var play_area := _play_area()
	var active_player_ids := []

	for index in range(_current_players.size()):
		var player = _current_players[index]

		if typeof(player) == TYPE_DICTIONARY:
			var player_data := player as Dictionary
			var player_id := str(player_data.get("id", ""))

			if not player_id.is_empty():
				active_player_ids.append(player_id)
				_sync_player_ship(player_data, index, _current_players.size(), play_area)

	for existing_player_id in _ships_by_player_id.keys():
		if not active_player_ids.has(existing_player_id):
			var ship := _ships_by_player_id[existing_player_id] as PlayerShip
			ship.queue_free()
			_ships_by_player_id.erase(existing_player_id)


func _sync_player_ship(player: Dictionary, index: int, player_count: int, play_area: Rect2) -> void:
	var player_id := str(player.get("id", ""))
	var player_name := str(player.get("name", "Player"))
	var ship := _ships_by_player_id.get(player_id) as PlayerShip

	if ship == null:
		ship = _player_ship(player, index, player_count, play_area)
		_ships_by_player_id[player_id] = ship

	ship.set_play_area(play_area)
	ship.set_player_name(player_name)
	ship.set_player_id(player_id)
	ship.set_player_index(index)
	ship.set_local_player(player_id == _local_player_id)
	ship.set_defeated(bool(player.get("defeated", false)))

	if player_id != _local_player_id:
		var position: Variant = _player_position(player)

		if position != null:
			ship.set_remote_position(position)


func _player_ship(player: Dictionary, index: int, player_count: int, play_area: Rect2) -> PlayerShip:
	var ship := player_ship_scene.instantiate() as PlayerShip
	var player_id := str(player.get("id", ""))
	var player_name := str(player.get("name", "Player"))
	var start_position := _ship_start_position(index, player_count, play_area)

	ships_layer.add_child(ship)
	ship.set_play_area(play_area)
	ship.set_start_position(start_position)
	ship.set_player_name(player_name)
	ship.set_player_id(player_id)
	ship.set_player_index(index)
	ship.set_local_player(player_id == _local_player_id)

	if player_id == _local_player_id:
		ship.position_changed.connect(_on_local_ship_position_changed)
		ship.shoot_requested.connect(_on_local_ship_shoot_requested)

	return ship


func _ship_start_position(index: int, player_count: int, play_area: Rect2) -> Vector2:
	var lane_count: int = max(player_count, 2)
	var spacing := play_area.size.x / float(lane_count + 1)
	var x := play_area.position.x + spacing * float(index + 1)
	var y := play_area.end.y - SHIP_BOTTOM_OFFSET
	return Vector2(x, y)


func _play_area() -> Rect2:
	var area_size := playfield.size

	if area_size == Vector2.ZERO:
		area_size = get_viewport_rect().size - Vector2(96, 320)

	var area_position := Vector2(PLAY_AREA_HORIZONTAL_MARGIN, PLAY_AREA_TOP_MARGIN)
	var area_margin := Vector2(
		PLAY_AREA_HORIZONTAL_MARGIN * 2.0,
		PLAY_AREA_TOP_MARGIN + PLAY_AREA_BOTTOM_MARGIN
	)
	return Rect2(area_position, area_size - area_margin)


func _schedule_sync_ships() -> void:
	if not is_inside_tree():
		return

	await get_tree().process_frame
	await get_tree().process_frame
	_sync_ships()


func _player_position(player: Dictionary) -> Variant:
	var raw_position: Variant = player.get("position")

	if typeof(raw_position) != TYPE_DICTIONARY:
		return null

	var position_data := raw_position as Dictionary
	var x: Variant = position_data.get("x")
	var y: Variant = position_data.get("y")

	if typeof(x) != TYPE_FLOAT and typeof(x) != TYPE_INT:
		return null

	if typeof(y) != TYPE_FLOAT and typeof(y) != TYPE_INT:
		return null

	return Vector2(float(x), float(y))


func _on_local_ship_position_changed(position: Vector2) -> void:
	_pending_local_position = position
	_has_pending_local_position = true


func _on_local_ship_shoot_requested(spawn_position: Vector2) -> void:
	var damage := _local_player_damage()
	var projectile_range := _local_projectile_range()
	_spawn_projectile(spawn_position, damage, projectile_range)
	local_player_shot.emit(spawn_position, damage, projectile_range)


func spawn_remote_projectile(player_id: String, shot_position: Vector2, damage: float, projectile_range: float) -> void:
	if player_id == _local_player_id:
		return

	_spawn_projectile(shot_position, damage, projectile_range)


func _spawn_projectile(spawn_position: Vector2, damage: float, projectile_range: float) -> void:
	var projectile := projectile_scene.instantiate() as Projectile
	projectiles_layer.add_child(projectile)
	projectile.position = spawn_position
	projectile.set_play_area(_play_area())
	projectile.set_damage(damage)
	projectile.set_range(projectile_range)
	projectile.enemy_hit.connect(_on_projectile_enemy_hit)


func destroy_enemy(enemy_id: String) -> void:
	var enemy := _enemies_by_id.get(enemy_id) as Enemy

	if enemy == null or not is_instance_valid(enemy):
		_enemies_by_id.erase(enemy_id)
		return

	enemy.destroy()
	_enemies_by_id.erase(enemy_id)


func _schedule_spawn_enemy_wave() -> void:
	if _enemy_wave_spawned or not is_inside_tree():
		return

	await get_tree().process_frame
	await get_tree().process_frame
	_spawn_enemy_wave()


func _spawn_enemy_wave() -> void:
	if _enemy_wave_spawned:
		return

	_enemy_wave_spawned = true
	var play_area := _play_area()
	var total_width := float(ENEMY_COLUMNS - 1) * ENEMY_SPACING.x
	var start_x := play_area.position.x + (play_area.size.x - total_width) / 2.0
	var start_y: float = play_area.position.y + max(26.0, play_area.size.y * 0.12)

	for row in range(ENEMY_ROWS):
		for column in range(ENEMY_COLUMNS):
			var enemy := enemy_scene.instantiate() as Enemy
			var enemy_index := row * ENEMY_COLUMNS + column
			var enemy_id := "enemy-%s" % str(enemy_index)
			var enemy_type_id: String = ENEMY_TYPE_ORDER[enemy_index]
			var enemy_type: Dictionary = ENEMY_TYPES[enemy_type_id]
			enemies_layer.add_child(enemy)
			_enemies_by_id[enemy_id] = enemy
			enemy.set_enemy_id(enemy_id)
			enemy.set_enemy_type(enemy_type_id, enemy_type)
			enemy.set_formation_position(Vector2(
				start_x + float(column) * ENEMY_SPACING.x,
				start_y + float(row) * ENEMY_SPACING.y
			))


func _process_enemy_attacks(delta: float) -> void:
	if not _enemy_wave_spawned or enemy_projectile_scene == null:
		return

	_enemy_shot_elapsed += delta
	if _enemy_shot_elapsed < ENEMY_SHOT_INTERVAL:
		return

	_enemy_shot_elapsed = 0.0
	var enemy_ids := _enemies_by_id.keys()
	if enemy_ids.is_empty():
		return

	var enemy_id: String = str(enemy_ids[_enemy_shot_index % enemy_ids.size()])
	_enemy_shot_index += 1
	var enemy := _enemies_by_id.get(enemy_id) as Enemy
	if enemy == null or not is_instance_valid(enemy):
		return

	var projectile = enemy_projectile_scene.instantiate()
	enemy_projectiles_layer.add_child(projectile)
	projectile.position = enemies_layer.position + enemy.position
	projectile.set_play_area(_play_area())
	projectile.set_damage(ENEMY_PROJECTILE_DAMAGE)
	projectile.player_hit.connect(_on_enemy_projectile_player_hit)


func _process_enemy_patterns(delta: float) -> void:
	if not _enemy_wave_spawned:
		return

	_enemy_wave_elapsed += delta

	for enemy_data in _enemies_by_id.values():
		var enemy := enemy_data as Enemy
		if enemy != null and is_instance_valid(enemy):
			enemy.update_pattern(_enemy_wave_elapsed)


func _on_enemy_projectile_player_hit(ship: PlayerShip, damage: float) -> void:
	if ship == null or ship.player_id != _local_player_id:
		return

	local_player_hit.emit(ship.player_id, damage)


func _on_projectile_enemy_hit(enemy_id: String, destroyed: bool) -> void:
	if enemy_id.is_empty() or not destroyed:
		return

	_enemies_by_id.erase(enemy_id)
	local_enemy_destroyed.emit(enemy_id)


func _local_player_damage() -> float:
	var state: Variant = _health_by_player_id.get(_local_player_id)

	if typeof(state) == TYPE_DICTIONARY:
		return float((state as Dictionary).get("damage", 24.0))

	return 24.0


func _local_projectile_range() -> float:
	var state: Variant = _health_by_player_id.get(_local_player_id)

	if typeof(state) == TYPE_DICTIONARY:
		return float((state as Dictionary).get("projectile_range", 520.0))

	return 520.0


func _process_enemy_wave(delta: float) -> void:
	if not _enemy_wave_spawned:
		return

	var play_area := _play_area()
	var wave_bounds := _enemy_wave_bounds()
	var next_offset := ENEMY_SPEED * _enemy_direction * delta

	if wave_bounds.position.x + next_offset < play_area.position.x:
		_enemy_direction = 1.0
		next_offset = play_area.position.x - wave_bounds.position.x
	elif wave_bounds.end.x + next_offset > play_area.end.x:
		_enemy_direction = -1.0
		next_offset = play_area.end.x - wave_bounds.end.x

	enemies_layer.position.x += next_offset


func _enemy_wave_bounds() -> Rect2:
	var has_bounds := false
	var min_x := 0.0
	var max_x := 0.0

	for child in enemies_layer.get_children():
		if child is Node2D:
			var enemy := child as Node2D
			var enemy_x := enemies_layer.position.x + enemy.position.x
			min_x = enemy_x if not has_bounds else min(min_x, enemy_x)
			max_x = enemy_x if not has_bounds else max(max_x, enemy_x)
			has_bounds = true

	if not has_bounds:
		return Rect2(Vector2.ZERO, Vector2.ZERO)

	return Rect2(Vector2(min_x - 34.0, 0.0), Vector2(max_x - min_x + 68.0, 1.0))


func _sync_player_health(players: Array) -> void:
	var active_player_ids := []

	for index in range(players.size()):
		var player = players[index]

		if typeof(player) != TYPE_DICTIONARY:
			continue

		var player_data := player as Dictionary
		var player_id := str(player_data.get("id", ""))

		if player_id.is_empty():
			continue

		active_player_ids.append(player_id)
		_ensure_player_health(player_id, index)

	for existing_player_id in _health_by_player_id.keys():
		if not active_player_ids.has(existing_player_id):
			_health_by_player_id.erase(existing_player_id)
			_health_rows_by_player_id.erase(existing_player_id)


func _ensure_player_health(player_id: String, player_index: int) -> void:
	var ship_class := _ship_class_for_index(player_index)
	var max_health := float(ship_class.get("max_health", 100.0))
	var current_state: Variant = _health_by_player_id.get(player_id)

	if typeof(current_state) == TYPE_DICTIONARY:
		var state := current_state as Dictionary
		state["class_name"] = str(ship_class.get("name", "Fighter"))
		state["max_health"] = max_health
		state["damage"] = float(ship_class.get("damage", 24.0))
		state["projectile_range"] = float(ship_class.get("projectile_range", 520.0))
		state["health"] = min(float(state.get("health", max_health)), max_health)
		return

	_health_by_player_id[player_id] = {
		"class_name": str(ship_class.get("name", "Fighter")),
		"health": max_health,
		"max_health": max_health,
		"damage": float(ship_class.get("damage", 24.0)),
		"projectile_range": float(ship_class.get("projectile_range", 520.0)),
	}


func apply_player_health(player_id: String, health: float, max_health: float, defeated: bool) -> void:
	var state := _health_by_player_id.get(player_id) as Dictionary
	if state == null:
		return

	state["health"] = clamp(health, 0.0, max_health)
	state["max_health"] = max_health
	state["defeated"] = defeated
	_update_health_row(player_id)

	var ship := _ships_by_player_id.get(player_id) as PlayerShip
	if ship != null and is_instance_valid(ship):
		ship.set_defeated(defeated)


func _ship_class_for_index(player_index: int) -> Dictionary:
	return SHIP_CLASSES[player_index % SHIP_CLASSES.size()]


func _render_health_hud(players: Array) -> void:
	var next_signature := _health_hud_signature_for_players(players)

	if next_signature == _health_hud_signature:
		for player_id in _health_rows_by_player_id.keys():
			_update_health_row(player_id)

		return

	_health_hud_signature = next_signature

	for child in health_hud.get_children():
		child.queue_free()

	_health_rows_by_player_id.clear()

	for index in range(players.size()):
		var player = players[index]

		if typeof(player) != TYPE_DICTIONARY:
			continue

		var player_data := player as Dictionary
		var player_id := str(player_data.get("id", ""))

		if player_id.is_empty():
			continue

		var row := _health_row(player_data, player_id, index)
		health_hud.add_child(row)
		_health_rows_by_player_id[player_id] = row
		_update_health_row(player_id)


func _health_hud_signature_for_players(players: Array) -> String:
	var parts := PackedStringArray()

	for index in range(players.size()):
		var player = players[index]

		if typeof(player) != TYPE_DICTIONARY:
			continue

		var player_data := player as Dictionary
		var player_id := str(player_data.get("id", ""))

		if player_id.is_empty():
			continue

		parts.append("%s:%s:%s" % [
			player_id,
			str(player_data.get("name", "Player")),
			str(index),
		])

	return "|".join(parts)


func _health_row(player: Dictionary, player_id: String, player_index: int) -> PanelContainer:
	var player_name := str(player.get("name", "Player"))
	var player_color: Color = PlayerShip.PLAYER_COLORS[player_index % PlayerShip.PLAYER_COLORS.size()]
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(250, 64)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _panel_style(player_color))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 4)
	margin.add_child(stack)

	var title := Label.new()
	title.name = "Title"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", player_color)
	title.add_theme_color_override("font_outline_color", Color(0.00784314, 0.00392157, 0.027451, 1.0))
	title.add_theme_constant_override("outline_size", 3)
	title.text = player_name
	stack.add_child(title)

	var bar := ProgressBar.new()
	bar.name = "HealthBar"
	bar.custom_minimum_size = Vector2(0, 14)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.max_value = 100.0
	bar.show_percentage = false
	bar.add_theme_stylebox_override("background", _bar_background_style())
	bar.add_theme_stylebox_override("fill", _bar_fill_style(player_color))
	stack.add_child(bar)

	var details := Label.new()
	details.name = "Details"
	details.add_theme_font_size_override("font_size", 13)
	details.add_theme_color_override("font_color", Color(0.917647, 1.0, 0.945098, 1.0))
	stack.add_child(details)

	return panel


func _update_health_row(player_id: String) -> void:
	var row := _health_rows_by_player_id.get(player_id) as PanelContainer
	var state := _health_by_player_id.get(player_id) as Dictionary

	if row == null or state == null:
		return

	var health := float(state.get("health", 100.0))
	var max_health := float(state.get("max_health", 100.0))
	var percent: float = 100.0 if max_health <= 0.0 else health / max_health * 100.0
	var title := row.find_child("Title", true, false) as Label
	var bar := row.find_child("HealthBar", true, false) as ProgressBar
	var details := row.find_child("Details", true, false) as Label

	if bar != null:
		bar.value = clamp(percent, 0.0, 100.0)

	if title != null and player_id == _local_player_id:
		title.text = "%s  YOU" % title.text.replace("  YOU", "")

	if details != null:
		details.text = "%s  %s%%  PWR %s  RNG %s" % [
			str(state.get("class_name", "Fighter")).to_upper(),
			str(roundi(percent)),
			str(roundi(float(state.get("damage", 24.0)))),
			str(roundi(float(state.get("projectile_range", 520.0))))
		]


func _panel_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.00784314, 0.00392157, 0.027451, 0.82)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(color.r, color.g, color.b, 0.9)
	return style


func _bar_background_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0196078, 0.0156863, 0.0745098, 0.95)
	return style


func _bar_fill_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	return style
