extends Node2D

@export var hits_to_break: int = 3
@export var shake_stregnth: float = 4.0
@export var shake_duration: float = 0.18

var hits_left: int
var is_broken := false

func _ready() -> void:
	hits_left = hits_to_break

func take_hit(direction: Vector2) -> void:
	if is_broken:
		return
	hits_left -= 1
	print("hits left: ", hits_left)
	if hits_left <= 0:
		break_block()
		return
	for tile in get_children():
		if tile.has_method("shake"):
			tile.shake(direction, shake_stregnth, shake_duration)

func break_block() -> void:
	if is_broken: return
	is_broken = true
	var longest_lifetime := 0.0
	for tile in get_children():
		if tile.has_method("break_effect"):
			var lifetime: float = tile.play_break_effect()
			longest_lifetime = maxf(longest_lifetime, lifetime)
	await get_tree().create_timer(longest_lifetime).timeout
	queue_free()
