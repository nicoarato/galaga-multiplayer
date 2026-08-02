extends Control
class_name HomeScreen

signal create_room_requested(player_name: String)
signal join_room_requested(player_name: String, room_id: String)

@onready var player_name_input: LineEdit = %PlayerNameInput
@onready var room_id_input: LineEdit = %RoomIdInput
@onready var create_room_button: Button = %CreateRoomButton
@onready var join_room_button: Button = %JoinRoomButton
@onready var status_label: Label = %StatusLabel


func _ready() -> void:
	create_room_button.pressed.connect(_on_create_room_pressed)
	join_room_button.pressed.connect(_on_join_room_pressed)
	player_name_input.text_changed.connect(_on_form_changed)
	room_id_input.text_changed.connect(_on_form_changed)
	_update_actions()


func set_status(message: String) -> void:
	status_label.text = message


func _on_create_room_pressed() -> void:
	var player_name := _player_name()

	if player_name.is_empty():
		set_status("Ingresa tu nombre para crear una partida.")
		return

	create_room_requested.emit(player_name)


func _on_join_room_pressed() -> void:
	var player_name := _player_name()
	var room_id := room_id_input.text.strip_edges()

	if player_name.is_empty():
		set_status("Ingresa tu nombre para unirte.")
		return

	if room_id.is_empty():
		set_status("Ingresa un codigo de sala.")
		return

	join_room_requested.emit(player_name, room_id)


func _on_form_changed(_new_text: String) -> void:
	_update_actions()


func _update_actions() -> void:
	var has_player_name := not _player_name().is_empty()
	create_room_button.disabled = not has_player_name
	join_room_button.disabled = not has_player_name or room_id_input.text.strip_edges().is_empty()


func _player_name() -> String:
	return player_name_input.text.strip_edges()
