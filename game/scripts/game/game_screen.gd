extends Control
class_name GameScreen

@export var player_ship_scene: PackedScene

@onready var room_id_label: Label = %RoomIdLabel
@onready var status_label: Label = %StatusLabel
@onready var players_list: VBoxContainer = %PlayersList
@onready var playfield: Control = %Playfield
@onready var ships_layer: Node2D = %ShipsLayer

var _local_player_id := ""
var _current_players: Array = []


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
	_schedule_render_ships()


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


func _render_ships() -> void:
	for child in ships_layer.get_children():
		child.queue_free()

	var play_area := _play_area()

	for index in range(_current_players.size()):
		var player = _current_players[index]

		if typeof(player) == TYPE_DICTIONARY:
			_player_ship(player as Dictionary, index, _current_players.size(), play_area)


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


func _schedule_render_ships() -> void:
	if not is_inside_tree():
		return

	await get_tree().process_frame
	await get_tree().process_frame
	_render_ships()
