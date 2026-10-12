extends StaticBody2D

@export var hits_to_break: int = 3
@export var shake_stregnth: float = 4.0
@export var shake_duration: float = 0.18
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var particles: CPUParticles2D = $CPUParticles2D

var _hits_left: int
var _sprite_home: Vector2
var _shake_tween: Tween
var _is_broken := false

func _ready() -> void:
	_hits_left = hits_to_break
	_sprite_home = sprite.position
	
func take_hit(hit_direction: Vector2) -> void:
	if _is_broken:
		return
	
	_hits_left -= 1
	print("block hit, hits left: ", _hits_left)
	
	if _hits_left <= 0:
		_break()
	else:
		_shake(hit_direction)
		
	

func _shake(hit_direction: Vector2) -> void:
	if _shake_tween:
		_shake_tween.kill()
	sprite.position = _sprite_home
	var dir := hit_direction.normalized()
	var steps := 4
	var step_time := shake_duration / (steps + 1)
	_shake_tween = create_tween()
	for i in steps:
		var falloff := 1.0 - float(i) / steps
		var flip := 1.0 if i % 2 == 0 else -1.0
		var jitter := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))*0.5
		var offset := (dir * flip + jitter) * shake_stregnth * falloff
		_shake_tween.tween_property(sprite, "position", _sprite_home + offset, step_time)
	_shake_tween.tween_property(sprite, "position", _sprite_home, step_time)

func _break() -> void:
	if _is_broken:
		return
		
	_is_broken = true
	
	collision.set_deferred("disabled", true)
	
	particles.emitting = true
	await get_tree().create_timer(particles.lifetime).timeout
	
	var block_root = get_parent()
	
	if block_root.has_method("break_block"):
		block_root.break_block()
	else:
		push_error("Parent node is missing break block")
		
	
