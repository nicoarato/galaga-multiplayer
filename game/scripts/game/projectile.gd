extends Node2D
class_name Projectile

const SPEED := 720.0

var _play_area := Rect2(Vector2.ZERO, Vector2(1280, 720))


func _process(delta: float) -> void:
	position.y -= SPEED * delta

	if position.y < _play_area.position.y - 32.0:
		queue_free()


func set_play_area(play_area: Rect2) -> void:
	_play_area = play_area
