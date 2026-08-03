extends Area2D
class_name Projectile

signal enemy_hit(enemy_id: String, destroyed: bool)

const SPEED := 720.0
const MAX_RANGE := 520.0

var _play_area := Rect2(Vector2.ZERO, Vector2(1280, 720))
var _has_hit := false
var _damage := 24.0
var _distance_traveled := 0.0


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	if _has_hit:
		return

	position.y -= SPEED * delta
	_distance_traveled += SPEED * delta

	if _distance_traveled >= MAX_RANGE:
		queue_free()
		return

	if position.y < _play_area.position.y - 32.0:
		queue_free()


func set_play_area(play_area: Rect2) -> void:
	_play_area = play_area


func set_damage(damage: float) -> void:
	_damage = max(damage, 0.0)


func _on_area_entered(area: Area2D) -> void:
	if _has_hit or not area is Enemy:
		return

	_has_hit = true
	var enemy := area as Enemy
	var destroyed := enemy.apply_damage(_damage)
	enemy_hit.emit(enemy.enemy_id, destroyed)
	queue_free()
