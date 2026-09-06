extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -300.0
var can_attack = true
@onready var sprite = $Sprite2D


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if GameManager.controls_allowed:
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
	
		var direction := Input.get_axis("left", "right")
	
		if direction:
			velocity.x = direction * SPEED
			sprite.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	if Input.is_action_just_pressed("Attack") && can_attack == true:
		velocity.x = 0
		GameManager.controls_allowed = false
