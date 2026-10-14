extends StaticBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var particles: GPUParticles2D = $BreakParticlesFX/GPUParticles2D

var original_position: Vector2
var shake_tween: Tween

func _ready() -> void:
	original_position = sprite.position

func take_hit(direction: Vector2) -> void:
	var group = get_parent()
	if group.has_method("take_hit"):
		group.take_hit(direction)
		
func shake(direction: Vector2, strength: float, duration: float) -> void:
	if shake_tween and shake_tween.is_running():
		shake_tween.kill()
	sprite.position = original_position
	var dir := direction.normalized()
	var step_time := duration / 5.0
	shake_tween = create_tween()
	for i in range(4):
		var flip := 1.0 if i % 2 == 0 else -1.0
		var falloff := 1.0 - float(i) / 4.0
		var offset := dir * flip * strength * falloff
		shake_tween.tween_property(sprite, "position", original_position + offset, step_time)
	shake_tween.tween_property(sprite, "position", original_position, step_time)

func play_break_effect() -> float:
	collision.set_deffered("disabled", true)
	particles.emitting = true
	return particles.lifetime
