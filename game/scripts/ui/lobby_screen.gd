extends Control
class_name LobbyScreen

signal back_requested()
signal ready_requested()
signal start_game_requested()

@onready var room_id_input: LineEdit = %RoomIdInput
@onready var connection_label: Label = %ConnectionLabel
@onready var players_label: Label = %PlayersLabel
@onready var players_list: VBoxContainer = %PlayersList
@onready var copy_room_button: Button = %CopyRoomButton
@onready var ready_button: Button = %ReadyButton
@onready var start_game_button: Button = %StartGameButton
@onready var back_button: Button = %BackButton

var _local_player_id := ""
var _local_ready := false


func _ready() -> void:
	copy_room_button.pressed.connect(_on_copy_room_pressed)
	ready_button.pressed.connect(ready_requested.emit)
	start_game_button.pressed.connect(start_game_requested.emit)
	back_button.pressed.connect(back_requested.emit)


func set_connection_status(message: String) -> void:
	connection_label.text = message


func set_room(room: Dictionary, local_player_id := "") -> void:
	if not local_player_id.is_empty():
		_local_player_id = local_player_id

	var room_id := str(room.get("id", ""))
	var host_player_id := str(room.get("hostPlayerId", ""))
	var players: Array = room.get("players", [])
	var is_host := not _local_player_id.is_empty() and _local_player_id == host_player_id

	room_id_input.text = room_id
	players_label.text = "%s PLAYER(S)" % str(players.size())
	_local_ready = _local_player_ready(players)
	ready_button.text = "UNREADY" if _local_ready else "READY"
	start_game_button.disabled = not is_host
	_render_players(players, host_player_id)


func _on_copy_room_pressed() -> void:
	DisplayServer.clipboard_set(room_id_input.text)
	set_connection_status("Room id copied")


func _render_players(players: Array, host_player_id: String) -> void:
	for child in players_list.get_children():
		child.queue_free()

	for player in players:
		if typeof(player) == TYPE_DICTIONARY:
			players_list.add_child(_player_row(player as Dictionary, host_player_id))


func _player_row(player: Dictionary, host_player_id: String) -> Label:
	var player_id := str(player.get("id", ""))
	var player_name := str(player.get("name", "Player"))
	var ready := bool(player.get("ready", false))
	var host_label := " HOST" if player_id == host_player_id else ""
	var local_label := " YOU" if player_id == _local_player_id else ""
	var row := Label.new()
	row.add_theme_color_override("font_color", Color(0.0862745, 0.941176, 1, 1))
	row.add_theme_font_size_override("font_size", 24)
	row.text = "%s%s%s  %s" % [player_name, host_label, local_label, "READY" if ready else "WAIT"]
	return row


func local_ready() -> bool:
	return _local_ready


func _local_player_ready(players: Array) -> bool:
	for player in players:
		if typeof(player) == TYPE_DICTIONARY:
			var player_data := player as Dictionary

			if str(player_data.get("id", "")) == _local_player_id:
				return bool(player_data.get("ready", false))

	return false
