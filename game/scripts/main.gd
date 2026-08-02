extends Control

@onready var home_screen = %HomeScreen
@onready var api_client = %ApiClient


func _ready() -> void:
	home_screen.create_room_requested.connect(_on_create_room_requested)
	home_screen.join_room_requested.connect(_on_join_room_requested)
	api_client.room_created.connect(_on_room_created)
	api_client.request_failed.connect(_on_request_failed)


func _on_create_room_requested(player_name: String) -> void:
	home_screen.set_status("Creando sala para %s..." % player_name)
	api_client.create_room()


func _on_join_room_requested(player_name: String, room_id: String) -> void:
	home_screen.set_status("Proximo paso: %s se une a %s." % [player_name, room_id])


func _on_room_created(room: Dictionary) -> void:
	home_screen.set_status("Sala creada: %s" % str(room.get("id", "")))


func _on_request_failed(message: String) -> void:
	home_screen.set_status(message)
