extends CharacterBody2D

enum Anim { IDLE, AGGRO, ATTACK, HIT, HURT, DIE }
var current_anim: Anim = Anim.IDLE 
var health: int = 2
var hover_speed: float = 60.0
var attack_speed: float = 100.0
var aggro_range: float = 160.0
var attack_range: float = 80
var target_player: Node2D = null
var is_recovering: bool = false
var knocked_back: bool = false
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	change_anim(Anim.IDLE)

func _process(delta: float) -> void:
	if current_anim == Anim.DIE:
		return
	find_player()
	if not knocked_back:
		match current_anim:
			Anim.IDLE:
				velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
				if target_player and global_position.distance_to(target_player.global_position) <= aggro_range:
					change_anim(Anim.AGGRO)
			
			Anim.AGGRO:
				if not target_player or global_position.distance_to(target_player.global_position) >= aggro_range:
					change_anim(Anim.IDLE)
					return
				sprite.flip_h = target_player.global_position.x < global_position.x
				var hover_target = target_player.global_position + Vector2(0, -40)
				var dir = (hover_target - global_position).normalized()
				velocity = dir * hover_speed
				if global_position.distance_to(target_player.global_position) <= attack_range and not is_recovering:
					change_anim(Anim.ATTACK)
			
			Anim.ATTACK:
				if target_player:
					var dir = (target_player.global_position - global_position).normalized()
					velocity = dir * attack_speed
					sprite.flip_h = dir.x < 0
	move_and_slide()

func change_anim(new_anim: Anim) -> void:
	current_anim = new_anim
	match current_anim:
		Anim.IDLE:
			sprite.play("idle")
		Anim.AGGRO:
			sprite.play("aggro")
		Anim.ATTACK:
			sprite.play("attack")
		Anim.HIT:
			sprite.play("hit")
		Anim.HURT:
			sprite.play("hurt")
		Anim.DIE:
			sprite.play("die")
			velocity = Vector2.ZERO
			$Hitbox/CollisionShape2D.set_deferred("disabled", true)
			$Hurtbox/CollisionShape2D.set_deferred("disabled", true)

func find_player() -> void:
	if not target_player:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target_player = players[0]

func _on_animation_finished() -> void:
	match current_anim:
		Anim.ATTACK:
			start_attack_cooldown()
			change_anim(Anim.AGGRO)
		Anim.HIT:
			start_attack_cooldown()
			change_anim(Anim.AGGRO)
		Anim.HURT:
			change_anim(Anim.AGGRO)
		Anim.DIE:
			queue_free()

func start_attack_cooldown() -> void:
	is_recovering = true
	await get_tree().create_timer(5).timeout
	is_recovering = false

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox") and current_anim == Anim.ATTACK:
		velocity = Vector2.ZERO
		change_anim(Anim.HIT)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	var push_dir = 1.0 if area.global_position.x < global_position.x else -1.0
	if area.is_in_group("player_attack") and current_anim != Anim.DIE:
		health -= 1
		print("Flying enemy health:", health)
		knocked_back = true
		velocity = Vector2(push_dir * 75, -80)
		change_anim(Anim.HURT)
		await get_tree().create_timer(0.5).timeout
		knocked_back = false
	if area.is_in_group("player_attack_up") and current_anim != Anim.DIE:
		health -= 1
		print("Flying enemy health:", health)
		knocked_back = true
		velocity = Vector2(0, -80)
		change_anim(Anim.HURT)
		await get_tree().create_timer(0.5).timeout
		knocked_back = false
	if area.is_in_group("player_attack_down") and current_anim != Anim.DIE:
		health -= 1
		print("Flying enemy health:", health)
		knocked_back = true
		velocity = Vector2(0, 80)
		change_anim(Anim.HURT)
		await get_tree().create_timer(0.5).timeout
		knocked_back = false
	if health <= 0:
		knocked_back = true
		velocity = Vector2(push_dir * 50, 50)
		change_anim(Anim.HURT)
		await get_tree().create_timer(0.75).timeout
		change_anim(Anim.DIE)

			
