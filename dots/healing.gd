extends CharacterBody2D

@export var horizontal_speed: float = 220.0
@export var normal_vertical_speed: float = 240.0
@export var falling_follow_speed: float = 85.0

@export var follow_offset: Vector2 = Vector2(-28, -18)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var player: CharacterBody2D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	
	if player == null:
		print("cant find player")
	else:
		print("found player")
		

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as CharacterBody2D
		
		if player == null:
			return
	
	var offset := follow_offset
	offset.x = -absf(follow_offset.x) * player.facing
	
	var target := player.global_position + offset
	
	var speed := normal_vertical_speed
	if player.velocity.y > 0.0:
		speed = falling_follow_speed
		 
	var movement := target - global_position
	
	velocity.x = move_toward(
		0.0, movement.x, horizontal_speed * delta
	) / maxf(delta, 0.001)
	
	velocity.y = move_toward(
		0.0, movement.y, speed * delta
	) / maxf(delta, 0.001)
	
	move_and_slide()
	print("pos:", global_position, "player:", player.global_position)
