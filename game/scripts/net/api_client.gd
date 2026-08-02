extends Node
class_name ApiClient

signal room_created(room: Dictionary)
signal request_failed(message: String)

var _create_room_request: HTTPRequest


func _ready() -> void:
	_create_room_request = HTTPRequest.new()
	add_child(_create_room_request)
	_create_room_request.request_completed.connect(_on_create_room_completed)


func create_room() -> void:
	var error := _create_room_request.request(
		AppConfig.api_url("/api/rooms"),
		PackedStringArray(["Content-Type: application/json"]),
		HTTPClient.METHOD_POST,
		"{}"
	)

	if error != OK:
		request_failed.emit("No se pudo iniciar la solicitud de sala.")


func _on_create_room_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		request_failed.emit("No se pudo conectar con el backend.")
		return

	if response_code != 201:
		request_failed.emit("El backend respondio con error %s." % str(response_code))
		return

	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())

	if typeof(parsed) != TYPE_DICTIONARY:
		request_failed.emit("Respuesta invalida del backend.")
		return

	var response: Dictionary = parsed as Dictionary
	var room: Variant = response.get("room")

	if typeof(room) != TYPE_DICTIONARY:
		request_failed.emit("La respuesta no incluyo la sala.")
		return

	room_created.emit(room as Dictionary)
