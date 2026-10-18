extends CharacterBody2D

@export var horizontal_speed: float = 220.0
@export var normal_vertical_speed: float = 240.0
@export var falling_follow_speed: float = 85.0

@export var follow_offset: Vector2 = Vector2(-28, -18)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var player: CharacterBody2D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	
	if animated_sprite.sprite_frames != null:
		if animated_sprite.sprite_frames.has_animation("movement"):
			animated_sprite.play("movement")
	
	if player != null:
		snap_to_player(player)
		print("found plauer")
		

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as CharacterBody2D
		
		if player == null:
			return
	
	update_facing()
	
	var target: Vector2 = player.global_position + get_follow_offset()
	var movement : Vector2 = target - global_position
	
	var vertical_speed: float = normal_vertical_speed
	
	if player.velocity.y > 0.0:
		vertical_speed = falling_follow_speed
		 
	
	velocity.x = move_toward(
		global_position.x, target.x, horizontal_speed * delta
	) - global_position.x
	
	velocity.y = move_toward(
		global_position.y, target.y, vertical_speed * delta
	) - global_position.y
	
	velocity /= maxf(delta, 0.001)
	
	move_and_slide()

func set_player(new_player: CharacterBody2D) -> void:
	player = new_player
	
func get_follow_offset() -> Vector2:
	var offset := follow_offset
	
	offset.x = -absf(follow_offset.x) * float(player.facing)
	return offset
	
func snap_to_player(new_player: CharacterBody2D) -> void:
	player = new_player
	
	if not is_instance_valid(player):
		return
	
	global_position = player.global_position + get_follow_offset()
	velocity = Vector2.ZERO
	
	update_facing()
	
func update_facing() -> void:
	if not is_instance_valid(player):
		return
		
	animated_sprite.flip_h = player.facing < 0
