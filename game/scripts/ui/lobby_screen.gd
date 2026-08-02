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


func _ready() -> void:
	copy_room_button.pressed.connect(_on_copy_room_pressed)
	ready_button.pressed.connect(ready_requested.emit)
	start_game_button.pressed.connect(start_game_requested.emit)
	back_button.pressed.connect(back_requested.emit)


func set_connection_status(message: String) -> void:
	connection_label.text = message


func set_room(room: Dictionary) -> void:
	var room_id := str(room.get("id", ""))
	var players: Array = room.get("players", [])

	room_id_input.text = room_id
	players_label.text = "%s PLAYER(S)" % str(players.size())
	_render_players(players)


func _on_copy_room_pressed() -> void:
	DisplayServer.clipboard_set(room_id_input.text)
	set_connection_status("Room id copied")


func _render_players(players: Array) -> void:
	for child in players_list.get_children():
		child.queue_free()

	for player in players:
		if typeof(player) == TYPE_DICTIONARY:
			players_list.add_child(_player_row(player as Dictionary))


func _player_row(player: Dictionary) -> Label:
	var player_name := str(player.get("name", "Player"))
	var ready := bool(player.get("ready", false))
	var row := Label.new()
	row.add_theme_color_override("font_color", Color(0.0862745, 0.941176, 1, 1))
	row.add_theme_font_size_override("font_size", 24)
	row.text = "%s  %s" % [player_name, "READY" if ready else "WAIT"]
	return row
