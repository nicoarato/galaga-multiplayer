extends Control

@onready var home_screen = %HomeScreen


func _ready() -> void:
	home_screen.create_room_requested.connect(_on_create_room_requested)
	home_screen.join_room_requested.connect(_on_join_room_requested)


func _on_create_room_requested(player_name: String) -> void:
	home_screen.set_status("Proximo paso: crear sala para %s." % player_name)


func _on_join_room_requested(player_name: String, room_id: String) -> void:
	home_screen.set_status("Proximo paso: %s se une a %s." % [player_name, room_id])
