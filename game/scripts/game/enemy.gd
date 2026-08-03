extends Area2D
class_name Enemy

const SPRITE_SHEET = preload("res://assets/enemies/enemy_variants_sheet.png")
const SPRITE_SCALE := 0.2
const SPRITE_REGIONS := {
	"drone": Rect2(0, 0, 355, 444),
	"zigzag": Rect2(355, 0, 355, 444),
	"shield": Rect2(710, 0, 354, 444),
	"tank": Rect2(1064, 0, 355, 444),
	"sprinter": Rect2(1419, 0, 355, 444),
	"shooter": Rect2(0, 444, 355, 443),
	"splitter": Rect2(355, 444, 355, 443),
	"diver": Rect2(710, 444, 354, 443),
	"support": Rect2(1064, 444, 355, 443),
	"elite": Rect2(1419, 444, 355, 443),
}

@onready var dome: Polygon2D = %Dome
@onready var body: Polygon2D = %Body
@onready var core: Polygon2D = %Core
@onready var left_light: Polygon2D = %LeftLight
@onready var right_light: Polygon2D = %RightLight
@onready var sprite: Sprite2D = %Sprite

var enemy_id := ""
var enemy_type_id := "drone"
var max_health := 48.0
var health := 48.0


func set_enemy_id(next_enemy_id: String) -> void:
	enemy_id = next_enemy_id


func set_enemy_health(next_max_health: float) -> void:
	max_health = max(next_max_health, 1.0)
	health = max_health


func set_enemy_type(next_enemy_type_id: String, stats: Dictionary) -> void:
	enemy_type_id = next_enemy_type_id
	set_enemy_health(float(stats.get("health", 48.0)))

	var color: Color = stats.get("color", Color(0.86, 1.0, 0.18, 1.0))
	var visual_scale := float(stats.get("scale", 1.0))
	scale = Vector2.ONE * visual_scale
	_apply_sprite(next_enemy_type_id)
	dome.color = Color(color.r, color.g, color.b, 0.72)
	body.color = color
	left_light.color = Color(1.0, color.g, color.b, 1.0)
	right_light.color = Color(color.r, 0.2, 1.0, 1.0)
	core.color = Color(0.00784314, 0.00392157, 0.027451, 1.0)


func _apply_sprite(next_enemy_type_id: String) -> void:
	var region: Rect2 = SPRITE_REGIONS.get(next_enemy_type_id, SPRITE_REGIONS["drone"])
	var atlas := AtlasTexture.new()
	atlas.atlas = SPRITE_SHEET
	atlas.region = region
	sprite.texture = atlas
	sprite.scale = Vector2.ONE * SPRITE_SCALE
	sprite.visible = true
	dome.visible = false
	body.visible = false
	core.visible = false
	left_light.visible = false
	right_light.visible = false


func apply_damage(amount: float) -> bool:
	health = max(health - max(amount, 0.0), 0.0)

	if health <= 0.0:
		destroy()
		return true

	return false


func destroy() -> void:
	queue_free()
