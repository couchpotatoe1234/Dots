extends CharacterBody2D

@export var horizontal_speed: float = 145.0
@export var normal_vertical_speed: float = 240.0
@export var falling_follow_speed: float = 85.0
@export var offset_change_time: float = 2.0
@export var follow_offset: Vector2 = Vector2(20, -60)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var player: CharacterBody2D
var is_repositioning: bool = false
var offset_timer: float = 0.0
var current_offset: Vector2 = Vector2(45, -10)
var target_offset: Vector2 = Vector2(20, -30)

var follow_offsets: Array[Vector2] = [
	Vector2(20, -40), Vector2(-20, -40),
	Vector2(20, -39), Vector2(-20, -39),
	Vector2(20, -38), Vector2(-20, -38),
	Vector2(20, -36), Vector2(-20, -37),
	Vector2(20, -36), Vector2(-20, -36),
	Vector2(20, -34), Vector2(-20, -34),
	Vector2(20, -32), Vector2(-20, -32),
]
func _ready() -> void:
	add_to_group("player")
	print("player ready")
	floor_snap_length = 4.0
	
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	
	if animated_sprite.sprite_frames != null:
		if animated_sprite.sprite_frames.has_animation("movement"):
			animated_sprite.play("movement")
	
	if player != null:
		snap_to_player(player)
		print("found plauer")
		

func _physics_process(delta: float) -> void:
	update_follow_offset(delta)
	if is_repositioning:
		velocity = Vector2.ZERO
		return
	
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
		 
	var step_x: float = horizontal_speed * delta
	var step_y: float  = vertical_speed * delta
	
	var next_x: float = move_toward(
		global_position.x, target.x, step_x
	)
	var next_y: float = move_toward(
		global_position.y, target.y, step_y
	)
	
	velocity = Vector2(
		(next_x - global_position.x) / maxf(delta, 0.001),
		(next_y - global_position.y) / maxf(delta, 0.001)
	)
	
	move_and_slide()

func set_player(new_player: CharacterBody2D) -> void:
	player = new_player
	
func get_follow_offset() -> Vector2:
	var offset := target_offset
	
	if not is_instance_valid(player):
		return offset
	
	if not "facing" in player:
		return offset
	
	offset.x = -absf(follow_offset.x) * float(player.facing)
	return offset
	
func snap_to_player(new_player: CharacterBody2D) -> void:
	is_repositioning = true
	player = new_player
	
	if not is_instance_valid(player):
		is_repositioning = false
		return
	
	global_position = player.global_position + get_follow_offset()
	velocity = Vector2.ZERO
	update_facing()
	
	is_repositioning = false
	
func update_facing() -> void:
	if not is_instance_valid(player):
		return
		
	if player.has_method("get_facing"):
		var should_flip: bool = player.get_facing() < 0
		animated_sprite.flip_h = should_flip
		
func update_follow_offset(delta: float) -> void:
	offset_timer += delta
	
	if offset_timer >= offset_change_time:
		offset_timer = 0.0
		
		var random_index = randi_range(0, follow_offsets.size() - 1)
		target_offset = follow_offsets[random_index]
		
	current_offset = current_offset.lerp(target_offset, delta * 3.0)
		
