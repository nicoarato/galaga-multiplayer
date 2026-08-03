extends Area2D
class_name Projectile

const SPEED := 720.0

var _play_area := Rect2(Vector2.ZERO, Vector2(1280, 720))
var _has_hit := false


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	if _has_hit:
		return

	position.y -= SPEED * delta

	if position.y < _play_area.position.y - 32.0:
		queue_free()


func set_play_area(play_area: Rect2) -> void:
	_play_area = play_area


func _on_area_entered(area: Area2D) -> void:
	if _has_hit or not area is Enemy:
		return

	_has_hit = true
	var enemy := area as Enemy
	enemy.destroy()
	queue_free()
