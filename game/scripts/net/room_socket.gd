extends Node
class_name RoomSocket

signal connected()
signal room_state_received(room: Dictionary)
signal game_started(room: Dictionary)
signal socket_failed(message: String)
signal socket_closed()

var _socket := WebSocketPeer.new()
var _is_connected := false
var _player_name := ""


func connect_to_room(room_id: String, player_name: String) -> void:
	close()
	_socket = WebSocketPeer.new()
	_player_name = player_name

	var error := _socket.connect_to_url(AppConfig.ws_url("/ws/rooms/%s" % room_id))

	if error != OK:
		socket_failed.emit("No se pudo conectar al lobby.")


func close() -> void:
	if _socket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		_socket.close()

	_is_connected = false


func _process(_delta: float) -> void:
	_socket.poll()

	var state := _socket.get_ready_state()

	if state == WebSocketPeer.STATE_OPEN:
		if not _is_connected:
			_is_connected = true
			connected.emit()
			_send_join_room()

		_read_packets()
		return

	if state == WebSocketPeer.STATE_CLOSED and _is_connected:
		_is_connected = false
		socket_closed.emit()


func _send_join_room() -> void:
	_send_json({
		"type": "join_room",
		"playerName": _player_name
	})


func _read_packets() -> void:
	while _socket.get_available_packet_count() > 0:
		var body := _socket.get_packet().get_string_from_utf8()
		_handle_message(body)


func _handle_message(body: String) -> void:
	var parsed: Variant = JSON.parse_string(body)

	if typeof(parsed) != TYPE_DICTIONARY:
		socket_failed.emit("Mensaje invalido del lobby.")
		return

	var message: Dictionary = parsed as Dictionary
	var message_type := str(message.get("type", ""))

	match message_type:
		"room_state":
			_emit_room_signal(message, room_state_received)
		"game_started":
			_emit_room_signal(message, game_started)
		"error":
			socket_failed.emit("Error de lobby: %s" % str(message.get("reason", "unknown")))
		"pong":
			pass
		_:
			socket_failed.emit("Mensaje de lobby no soportado: %s" % message_type)


func _emit_room_signal(message: Dictionary, target_signal: Signal) -> void:
	var room: Variant = message.get("room")

	if typeof(room) != TYPE_DICTIONARY:
		socket_failed.emit("El mensaje no incluyo la sala.")
		return

	target_signal.emit(room as Dictionary)


func _send_json(message: Dictionary) -> void:
	_socket.send_text(JSON.stringify(message))
