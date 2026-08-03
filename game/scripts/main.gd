extends Control

@onready var home_screen = %HomeScreen
@onready var lobby_screen = %LobbyScreen
@onready var game_screen = %GameScreen
@onready var api_client = %ApiClient
@onready var room_socket = %RoomSocket

var _current_player_name := ""
var _flow_state := "home"
var _local_player_id := ""


func _ready() -> void:
	home_screen.create_room_requested.connect(_on_create_room_requested)
	home_screen.join_room_requested.connect(_on_join_room_requested)
	lobby_screen.back_requested.connect(_on_lobby_back_requested)
	lobby_screen.ready_requested.connect(_on_lobby_ready_requested)
	lobby_screen.start_game_requested.connect(_on_lobby_start_game_requested)
	api_client.room_created.connect(_on_room_created)
	api_client.request_failed.connect(_on_request_failed)
	room_socket.connected.connect(_on_room_socket_connected)
	room_socket.room_state_received.connect(_on_room_state_received)
	room_socket.game_started.connect(_on_game_started)
	room_socket.socket_failed.connect(_on_request_failed)
	room_socket.socket_error.connect(_on_socket_error)
	room_socket.socket_closed.connect(_on_room_socket_closed)
	_show_home()


func _on_create_room_requested(player_name: String) -> void:
	_current_player_name = player_name
	_local_player_id = ""
	_flow_state = "connecting"
	home_screen.set_status("Creando sala para %s..." % player_name)
	api_client.create_room()


func _on_join_room_requested(player_name: String, room_id: String) -> void:
	_current_player_name = player_name
	_local_player_id = ""
	_flow_state = "connecting"
	home_screen.set_status("Conectando a sala %s..." % room_id)
	room_socket.connect_to_room(room_id, player_name)


func _on_room_created(room: Dictionary) -> void:
	var room_id := str(room.get("id", ""))

	if room_id.is_empty():
		home_screen.set_status("El backend no devolvio un id de sala.")
		return

	home_screen.set_status("Sala creada: %s. Conectando lobby..." % room_id)
	room_socket.connect_to_room(room_id, _current_player_name)


func _on_request_failed(message: String) -> void:
	if lobby_screen.visible:
		lobby_screen.set_connection_status(message)
	else:
		home_screen.set_status(message)


func _on_room_socket_connected() -> void:
	home_screen.set_status("Lobby conectado. Entrando a la sala...")
	lobby_screen.set_connection_status("Connected")


func _on_room_state_received(room: Dictionary) -> void:
	var players: Array = room.get("players", [])
	_local_player_id = _find_local_player_id(players)
	home_screen.set_status("Lobby conectado: %s jugador(es)." % str(players.size()))
	lobby_screen.set_room(room, _local_player_id)
	lobby_screen.set_connection_status("Connected")
	_flow_state = "lobby"
	_show_lobby()


func _on_room_socket_closed() -> void:
	if _flow_state == "lobby":
		lobby_screen.set_connection_status("Connection closed")
	else:
		home_screen.set_status("Conexion de lobby cerrada.")


func _on_lobby_back_requested() -> void:
	_flow_state = "home"
	room_socket.close(true)
	home_screen.set_status("Backend local: http://localhost:3000")
	_show_home()


func _on_lobby_ready_requested() -> void:
	room_socket.set_ready(not lobby_screen.local_ready())


func _on_lobby_start_game_requested() -> void:
	room_socket.start_game()


func _show_home() -> void:
	_flow_state = "home"
	home_screen.visible = true
	lobby_screen.visible = false
	game_screen.visible = false


func _show_lobby() -> void:
	home_screen.visible = false
	lobby_screen.visible = true
	game_screen.visible = false


func _show_game() -> void:
	_flow_state = "game"
	home_screen.visible = false
	lobby_screen.visible = false
	game_screen.visible = true


func _on_socket_error(reason: String) -> void:
	var message := _lobby_error_message(reason)

	if _flow_state == "lobby":
		lobby_screen.set_connection_status(message)
	else:
		room_socket.close()
		_flow_state = "home"
		home_screen.set_status(message)


func _on_game_started(room: Dictionary) -> void:
	lobby_screen.set_room(room, _local_player_id)
	lobby_screen.set_connection_status("Game starting...")
	game_screen.set_room(room)
	_show_game()


func _find_local_player_id(players: Array) -> String:
	for player in players:
		if typeof(player) == TYPE_DICTIONARY:
			var player_data := player as Dictionary

			if str(player_data.get("name", "")) == _current_player_name:
				return str(player_data.get("id", ""))

	return _local_player_id


func _lobby_error_message(reason: String) -> String:
	match reason:
		"room_not_found":
			return "Sala no encontrada."
		"room_full":
			return "Sala llena."
		"game_already_started", "already_started":
			return "La partida ya empezo."
		"player_not_joined":
			return "Todavia no entraste a la sala."
		"player_not_found":
			return "Jugador no encontrado."
		"not_host":
			return "Solo el host puede hacer eso."
		"players_not_ready":
			return "Faltan jugadores listos."
		"connection_failed":
			return "No se pudo conectar al lobby."
		_:
			return "Error de lobby."
