extends Node2D
class_name PlayerShip

const MOVE_SPEED := 260.0
const PLAYER_COLORS := [
	Color(1.0, 1.0, 1.0, 1.0),
	Color(1.0, 0.38, 0.82, 1.0),
	Color(0.52, 1.0, 0.44, 1.0),
	Color(1.0, 0.92, 0.2, 1.0),
]

@onready var team_halo: Polygon2D = %TeamHalo
@onready var sprite: Sprite2D = %Sprite
@onready var name_label: Label = %NameLabel
@onready var player_badge: Label = %PlayerBadge
@onready var local_marker: Label = %LocalMarker

var _is_local_player := false
var _player_name := "Player"
var _player_label := "P1"
var _play_area := Rect2(Vector2.ZERO, Vector2(1280, 720))
var _player_color := PLAYER_COLORS[0]


func _ready() -> void:
	_apply_visual_state()


func _process(delta: float) -> void:
	if not _is_local_player:
		return

	var direction := _input_direction()

	if direction == Vector2.ZERO:
		return

	position += direction * MOVE_SPEED * delta
	position = position.clamp(_play_area.position, _play_area.end)


func set_player_name(player_name: String) -> void:
	_player_name = player_name
	_apply_visual_state()


func set_local_player(is_local_player: bool) -> void:
	_is_local_player = is_local_player
	local_marker.visible = is_local_player
	_apply_visual_state()


func set_player_index(player_index: int) -> void:
	_player_color = PLAYER_COLORS[player_index % PLAYER_COLORS.size()]
	_player_label = "P%s" % str(player_index + 1)
	_apply_visual_state()


func set_play_area(play_area: Rect2) -> void:
	_play_area = play_area
	position = position.clamp(_play_area.position, _play_area.end)


func set_start_position(start_position: Vector2) -> void:
	position = start_position.clamp(_play_area.position, _play_area.end)


func _input_direction() -> Vector2:
	var direction := Vector2.ZERO

	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direction.x -= 1.0

	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction.x += 1.0

	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		direction.y -= 1.0

	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		direction.y += 1.0

	return direction.normalized()


func _apply_visual_state() -> void:
	if not is_node_ready():
		return

	team_halo.color = Color(_player_color.r, _player_color.g, _player_color.b, 0.72 if _is_local_player else 0.48)
	sprite.modulate = _player_color
	sprite.self_modulate.a = 1.0 if _is_local_player else 0.82
	name_label.text = _player_name
	name_label.add_theme_color_override("font_color", Color(1.0, 0.952941, 0.141176, 1.0) if _is_local_player else _player_color)
	player_badge.text = _player_label
	player_badge.add_theme_color_override("font_color", _player_color)
