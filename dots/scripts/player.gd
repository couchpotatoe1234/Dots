extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -325.0
var can_attack = true
var current_state = ""
var fall_height: float = 0.0
@export var is_attacking: bool = false
@onready var sprite = $Sprite2D
@onready var animation = $AnimationPlayer
var health: int = 50
var is_invulnerable: bool = false
var knocked_back: bool = false

func _ready() -> void:
	change_state("idle")
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	var input_dir := 0.0
	if GameManager.controls_allowed:
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			animation.play("Jump")
			velocity.y = JUMP_VELOCITY
		if Input.is_action_just_released("Jump") and not is_on_floor():
			if velocity.y < 0:
				velocity.y = 0
		
		input_dir = Input.get_axis("left", "right")
		if input_dir && not is_attacking:
			velocity.x = input_dir * SPEED
			var is_left = input_dir < 0
			if not is_attacking:
				sprite.flip_h = is_left
				$Attack.scale.x = -1 if is_left else 1


		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		if Input.is_action_just_pressed("Attack"):
			change_state("Attack")
			velocity.x = 0
	move_and_slide()
	
	update_state(input_dir)
	
func update_state(input_dir: float) -> void:
	if current_state in ["Attack", "run-transition", "Jump", "hurt"]:
		return
	
	if not is_on_floor():
		if current_state != "airtime":
			fall_height = global_position.y
		else:
			fall_height = min(fall_height, global_position.y)
		change_state("airtime")
		return
		
	if current_state == "airtime":
		var fall_distance = global_position.y - fall_height
		if fall_distance >= 96:
			change_state("fall")
			return
		else:
			current_state = ""
		
	if input_dir != 0:
		if current_state != "run":
			change_state("run-transition")
	else:
			change_state("idle")

func change_state(new_state: String) -> void:
	if current_state == new_state:
		return
		
	current_state = new_state
	animation.play(new_state)
	
func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "run-transition":
		current_state = "run"
		animation.play("run")
	elif anim_name == "Jump":
		current_state = "airtime"
		animation.play("airtime")
	elif anim_name == "fall":
		current_state = "idle"
		animation.play("idle")
	elif anim_name == "Attack" or anim_name == "hurt":
		current_state = ""
		change_state("idle")

func take_damage(amount: int) -> void:
	if is_invulnerable:
		return
	health -= amount
	print("Player health now:", health)
	var knock_dir = 1.0 if sprite.flip_h or scale.x < 0 else -1.0
	velocity.x = knock_dir * 100.0
	velocity.y = -200
	if $Camera2D:
		var tween = create_tween()
		for i in 10:
			tween.tween_property($Camera2D, "offset", Vector2(randf_range(-8, 8), randf_range(-8, 8)), 0.05)
		tween.tween_property($Camera2D, "offset", Vector2.ZERO, 0.05)
	if health <= 0:
		die()
	else:
		start_invulnerablilty()
		GameManager.controls_allowed = false
		await get_tree().create_timer(0.25).timeout
		GameManager.controls_allowed = true

func start_invulnerablilty() -> void:
	is_invulnerable = true
	change_state("hurt")
	await get_tree().create_timer(0.75).timeout
	sprite.modulate.a = 1.0
	is_invulnerable = false

func die() -> void:
	GameManager.controls_allowed = false
	print("ya died dummy")
	get_tree().reload_current_scene()


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("normal_enemy"):
		take_damage(1)
	if area.is_in_group("strong_enemy"):
		take_damage(2)
		
