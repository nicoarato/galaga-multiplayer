extends Control
class_name ScrollingBackground

const FAR_SPEED := 8.0
const NEAR_SPEED := 24.0

@onready var far_a: TextureRect = %FarA
@onready var far_b: TextureRect = %FarB
@onready var near_a: TextureRect = %NearA
@onready var near_b: TextureRect = %NearB

var _far_speed := FAR_SPEED
var _near_speed := NEAR_SPEED


func _ready() -> void:
	resized.connect(_reset_layers)
	call_deferred("_reset_layers")


func _process(delta: float) -> void:
	if size.y <= 0.0:
		return

	_scroll_pair(far_a, far_b, _far_speed, delta)
	_scroll_pair(near_a, near_b, _near_speed, delta)


func set_city_style(far_color: Color, near_color: Color, speed_multiplier: float) -> void:
	_far_speed = FAR_SPEED * speed_multiplier
	_near_speed = NEAR_SPEED * speed_multiplier
	far_a.modulate = far_color
	far_b.modulate = far_color
	near_a.modulate = near_color
	near_b.modulate = near_color


func _reset_layers() -> void:
	if size.y <= 0.0:
		return

	for layer in [far_a, far_b, near_a, near_b]:
		layer.size = size

	far_a.position = Vector2(0.0, -size.y)
	far_b.position = Vector2.ZERO
	near_a.position = Vector2(0.0, -size.y)
	near_b.position = Vector2.ZERO


func _scroll_pair(first: TextureRect, second: TextureRect, speed: float, delta: float) -> void:
	for layer in [first, second]:
		layer.position.y += speed * delta

		if layer.position.y >= size.y:
			layer.position.y -= size.y * 2.0
