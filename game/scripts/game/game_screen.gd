extends Control
class_name GameScreen

signal local_player_position_changed(position: Vector2)

const POSITION_SEND_INTERVAL := 0.05

@export var player_ship_scene: PackedScene
@export var projectile_scene: PackedScene

@onready var room_id_label: Label = %RoomIdLabel
@onready var status_label: Label = %StatusLabel
@onready var players_list: VBoxContainer = %PlayersList
@onready var playfield: Control = %Playfield
@onready var ships_layer: Node2D = %ShipsLayer
@onready var projectiles_layer: Node2D = %ProjectilesLayer

var _local_player_id := ""
var _current_players: Array = []
var _ships_by_player_id := {}
var _pending_local_position := Vector2.ZERO
var _has_pending_local_position := false
var _position_send_elapsed := 0.0


func _process(delta: float) -> void:
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
	_schedule_sync_ships()


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
	ship.set_player_index(index)
	ship.set_local_player(player_id == _local_player_id)

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
	var y := play_area.position.y + play_area.size.y - 60.0
	return Vector2(x, y)


func _play_area() -> Rect2:
	var area_size := playfield.size

	if area_size == Vector2.ZERO:
		area_size = get_viewport_rect().size - Vector2(96, 320)

	var ship_margin := Vector2(96, 104)
	return Rect2(ship_margin, area_size - ship_margin * 2.0)


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
	var projectile := projectile_scene.instantiate() as Projectile
	projectiles_layer.add_child(projectile)
	projectile.position = spawn_position
	projectile.set_play_area(_play_area())
