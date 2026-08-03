extends Area2D
class_name EnemyProjectile

signal player_hit(ship: PlayerShip, damage: float)

const SPEED := 220.0
const MAX_RANGE := 360.0

var _play_area := Rect2(Vector2.ZERO, Vector2(1280, 720))
var _damage := 12.0
var _has_hit := false
var _distance_traveled := 0.0


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	if _has_hit:
		return

	position.y += SPEED * delta
	_distance_traveled += SPEED * delta

	if _distance_traveled >= MAX_RANGE:
		queue_free()
		return

	if position.y > _play_area.end.y + 32.0:
		queue_free()


func set_play_area(play_area: Rect2) -> void:
	_play_area = play_area


func set_damage(damage: float) -> void:
	_damage = max(damage, 0.0)


func _on_area_entered(area: Area2D) -> void:
	if _has_hit:
		return

	var ship := area.get_parent() as PlayerShip
	if ship == null:
		return

	_has_hit = true
	player_hit.emit(ship, _damage)
	queue_free()
