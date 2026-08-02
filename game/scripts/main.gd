extends Control

@onready var home_screen = %HomeScreen
@onready var lobby_screen = %LobbyScreen
@onready var api_client = %ApiClient
@onready var room_socket = %RoomSocket

var _current_player_name := ""


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
	room_socket.socket_failed.connect(_on_request_failed)
	room_socket.socket_closed.connect(_on_room_socket_closed)
	_show_home()


func _on_create_room_requested(player_name: String) -> void:
	_current_player_name = player_name
	home_screen.set_status("Creando sala para %s..." % player_name)
	api_client.create_room()


func _on_join_room_requested(player_name: String, room_id: String) -> void:
	home_screen.set_status("Proximo paso: %s se une a %s." % [player_name, room_id])


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
	home_screen.set_status("Lobby conectado: %s jugador(es)." % str(players.size()))
	lobby_screen.set_room(room)
	lobby_screen.set_connection_status("Connected")
	_show_lobby()


func _on_room_socket_closed() -> void:
	if lobby_screen.visible:
		lobby_screen.set_connection_status("Connection closed")
	else:
		home_screen.set_status("Conexion de lobby cerrada.")


func _on_lobby_back_requested() -> void:
	room_socket.close()
	home_screen.set_status("Backend local: http://localhost:3000")
	_show_home()


func _on_lobby_ready_requested() -> void:
	lobby_screen.set_connection_status("Ready action pending")


func _on_lobby_start_game_requested() -> void:
	lobby_screen.set_connection_status("Start game pending")


func _show_home() -> void:
	home_screen.visible = true
	lobby_screen.visible = false


func _show_lobby() -> void:
	home_screen.visible = false
	lobby_screen.visible = true
