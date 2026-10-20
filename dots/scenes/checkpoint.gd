extends Node2D

@export var inactive_texture: Texture2D
@export var activated_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt: Label = $Label
@onready var animated_sprite = $AnimatedSprite2D
var player_in_range: bool = false
var activated: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite.frame = 1
	prompt.hide()
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_in_range and not activated:
		if Input.is_action_just_pressed("interact"):
			activate_checkpoint()
			
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		
		if not activated:
			prompt.show()
			
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		prompt.hide()
		
func activate_checkpoint() -> void:
	if activated:
		return
		
	activated = true
	
	GameManager.set_checkpoint(
		get_tree().current_scene.scene_file_path,
		global_position
	)
	prompt.hide()
	
	await get_tree().process_frame
	animated_sprite.frame = 2
