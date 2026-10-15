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
		push_warning("cant find player")
		
	
func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as CharacterBody2D
		
		if not is_instance_valid(player):
			return
		
	var offset := follow_offset
	offset.x = -absf(follow_offset.x) * player.facing
	
	var target := player.global_position + offset
	
	var vertical_speed := normal_vertical_speed
	if player.velocity.y > 0.0:
		vertical_speed * delta
		
	var next_position := Vector2(
		move_toward(global_position.x, target.x, horizontal_speed * delta),
		move_toward(global_position.y, target.y, vertical_speed * delta)
	)
	
	velocity = (next_position - global_position) / delta
	move_and_slide()
	
	if animated_sprite.sprite_frames.has_animation("movement"):
		if not animated_sprite.is_playing():
			animated_sprite.play("movement")
