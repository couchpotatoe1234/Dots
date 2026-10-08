extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -325.0
const ATTACK_COOLDOWN : float = 0.4
@export var unturnable: bool = false
@export var max_health: int = 5
@onready var sprite = $PlayerSprite
@onready var animation = $AnimationPlayer
@onready var transition_layer = $"../GUI/TransitionLayer"
@onready var camera = $"Camera2D"
var current_state = ""
var fall_height: float = 0.0
var health: int = 5
var is_invulnerable: bool = false
var knocked_back: bool = false
var attack_cooldown_timer : float = 0.0
var can_attack: bool = true
signal load_main_menu
signal health_changed(current_health: int, max_health: int)

func _ready() -> void:
	health_changed.emit(health, max_health)
	is_invulnerable = false
	change_state("idle")
	
func _physics_process(delta: float) -> void:
	if attack_cooldown_timer > 0.0:
		attack_cooldown_timer -= delta
	GameManager.player_x = global_position.x
	if is_on_floor() and current_state == "attack-down":
		animation.stop()
		change_state("idle")
		unturnable = false
		$"Attack-down/Down".set_deferred("disabled", true)
		$PlayerSprite/Slash.visible = false
	if not is_on_floor():
		velocity += get_gravity() * delta
	var input_dir := 0.0
	if GameManager.controls_allowed:
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		if Input.is_action_just_released("Jump") and not is_on_floor():
			if velocity.y < 0:
				velocity.y = 0
		
		input_dir = Input.get_axis("left", "right")
		
		if input_dir:
			velocity.x = input_dir * SPEED
			var is_left = input_dir < 0
			if not unturnable:
				sprite.flip_h = is_left
				$PlayerSprite/Slash.flip_h = is_left
				$"Attack-side".scale.x = -1 if is_left else 1

		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		if Input.is_action_just_pressed("Attack"):
			if attack_cooldown_timer <= 0.0 && can_attack:
				attack()
			else:
				pass
		
	move_and_slide()
	update_state(input_dir)
	
func update_state(input_dir: float) -> void:
	if current_state in ["attack-side", "attack-up", "attack-down", "run-transition", "hurt", "die"]:
		if is_invulnerable && current_state in ["attack-side", "attack-up", "attack-down"]:
			animation.stop()
			$"Attack-down/Down".set_deferred("disabled", true)
			$"Attack-up/Up".set_deferred("disabled", true)
			$"Attack-side/Side".set_deferred("disabled", true)
			start_invulnerablilty()
		else:
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
	elif anim_name == "fall":
		current_state = "idle"
		animation.play("idle")
	elif anim_name == "attack-side" or anim_name == "hurt" or anim_name == "attack-up" or anim_name == "attack-down":
		current_state = ""
		change_state("idle")
	elif anim_name == "die":
		print("emited")
		health_changed.emit(health, max_health)
		health = max_health
		is_invulnerable = false
		load_main_menu.emit()
		
func take_damage(amount: int) -> void:
	if is_invulnerable:
		return
	unturnable = false
	health -= amount
	health_changed.emit(health, max_health)
	print("Player health now:", health)
	var knock_dir = 1.0 if sprite.flip_h or scale.x < 0 else -1.0
	velocity.x = knock_dir * 100.0
	velocity.y = -200
	if camera:
		var tween = create_tween()
		for i in 10:
			tween.tween_property(camera, "offset", Vector2(randf_range(-8, 8), randf_range(-8, 8)), 0.05)
		tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)
	if health <= 0:
		die()
	else:
		start_invulnerablilty()
		GameManager.controls_allowed = false
		await get_tree().create_timer(0.2).timeout
		GameManager.controls_allowed = true

func start_invulnerablilty() -> void:
	is_invulnerable = true
	unturnable = false
	can_attack = false
	$PlayerSprite/Slash.visible = false
	change_state("hurt")
	await get_tree().create_timer(0.5).timeout
	can_attack = true
	await get_tree().create_timer(0.25).timeout
	unturnable = false
	is_invulnerable = false
	await get_tree().create_timer(0.5).timeout
	check_for_hazards()

func die() -> void:
	is_invulnerable = true
	GameManager.controls_allowed = false
	velocity.x = 0
	velocity.y = 0
	print("ya died dummy")
	change_state("die")

func attack() -> void:
	attack_cooldown_timer = ATTACK_COOLDOWN
	if Input.is_action_pressed("up"):
		change_state("attack-up")
	elif Input.is_action_pressed("down") && not is_on_floor():
		change_state("attack-down")
	else:
		change_state("attack-side")
	
func respawn_at_checkpoint() -> void:
	if is_invulnerable:
		return
	transition_layer.fade_out()
	$PlayerSprite/Slash.visible = false
	unturnable = false
	if camera:
		var tween = create_tween()
		for i in 10:
			tween.tween_property(camera, "offset", Vector2(randf_range(-8, 8), randf_range(-8, 8)), 0.05)
		tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)
	change_state("hurt")
	GameManager.controls_allowed = false
	is_invulnerable = true
	velocity.y = -250
	velocity.x = 0
	health -= 1
	health_changed.emit(health, max_health)
	print("Player health now:", health)
	if health <= 0:
		die()
		return
	await transition_layer.fade_out() 
	global_position = GameManager.last_respawn_position
	transition_layer.fade_in()
	change_state("idle")
	await get_tree().create_timer(0.5).timeout
	is_invulnerable = false
	GameManager.controls_allowed = true
	
func _on_game_started() -> void:
	health_changed.emit(health, max_health)
	sprite.flip_h = false
	velocity = Vector2.ZERO

func _on_changed_level() -> void:
	camera.drag_horizontal_enabled = false
	camera.drag_vertical_enabled = false
	await get_tree().create_timer(0.01).timeout
	camera.drag_horizontal_enabled = true
	camera.drag_vertical_enabled = true

func check_for_hazards() -> void:
	if is_invulnerable:
		return
	for area in $Hurtbox.get_overlapping_areas():
		if area.is_in_group("normal_enemy"):
			take_damage(1)
			break
		if area.is_in_group("hazard"):
			respawn_at_checkpoint()

func _pogo(area: Area2D) -> void:
	if area.is_in_group("pogoable") && current_state == "attack-down":
		velocity.y = -300
		GameManager.hitstop(0.05)

func _damaged(area: Area2D) -> void:
	if is_invulnerable:
		return
	if area.is_in_group("normal_enemy"):
		unturnable = false
		take_damage(1)
	if area.is_in_group("strong_enemy"):
		unturnable = false
		take_damage(2)
	if area.is_in_group("normal_hazard"):
		unturnable = false
		respawn_at_checkpoint()

func _enemy_hit(area: Area2D) -> void:
	if area.is_in_group("normal_enemy"):
		GameManager.controls_allowed = false
		var hitback_dir = 1.0 if sprite.flip_h or scale.x < 0 else -1.0
		velocity.y = -25
		velocity.x = 100 * hitback_dir
		GameManager.hitstop(0.05)
		await get_tree().create_timer(0.2).timeout
		GameManager.controls_allowed = true
