extends Control
class_name GameScreen

@onready var room_id_label: Label = %RoomIdLabel
@onready var status_label: Label = %StatusLabel
@onready var players_list: VBoxContainer = %PlayersList


func set_room(room: Dictionary) -> void:
	var room_id := str(room.get("id", ""))
	var status := str(room.get("status", "in_game"))
	var players: Array = room.get("players", [])

	room_id_label.text = "ROOM %s" % room_id
	status_label.text = "Status: %s" % status.to_upper()
	_render_players(players)


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
