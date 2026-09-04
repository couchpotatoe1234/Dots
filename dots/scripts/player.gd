extends CharacterBody2D

var movement_speed = 150
var jump_height = -300

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	if GameManager.controls_allowed:
		if Input.is_action_just_pressed("up"):
			velocity.y = jump_height
		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * movement_speed
			
	
