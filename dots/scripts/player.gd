extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -300.0
var can_attack = true
var turning = false
var trans_run = false
var running = false
@onready var sprite = $Sprite2D
@onready var animation = $AnimationPlayer

func _ready() -> void:
	animation.play("idle")
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if GameManager.controls_allowed:
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			animation.play("Jump")
			running = false
		if Input.is_action_just_released("Jump") and not is_on_floor():
			if velocity.y > 0:
				velocity.y = 0
		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
			sprite.flip_h = direction < 0
			if is_on_floor():
				if not running:
					animation.play("run-transition")
					animation.queue("run")
					running = true
				elif animation.current_animation != "run-transition" and animation.current_animation != "run":
					animation.play("run")
		else:
			running = false
			velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() && not turning && not running:
			animation.play("idle")
		#if not is_on_floor() && velocity.y > 0:
			#animation.play("fall")
	move_and_slide()
	
