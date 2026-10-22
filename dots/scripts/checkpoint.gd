extends Area2D

@onready var prompt: Label = get_node_or_null("Label")
@onready var sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
var player_in_range: bool = false
var activated: bool = false

func _ready() -> void:
	
	if sprite == null:
		push_error("missing")
		return
	
	sprite.play("notactivated")
	prompt.hide()
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	

func _process(_delta: float) -> void:
	if GameManager.last_level == owner.scene_file_path:
		sprite.play("activated")
	if player_in_range and not activated:
		if Input.is_action_just_pressed("up"):
			activate_checkpoint()
			
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		if not activated and is_instance_valid(prompt):
			prompt.show()
			
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if is_instance_valid(prompt):
			prompt.visible = false

func activate_checkpoint() -> void:
	if activated:
		return

	if not is_instance_valid(sprite):
		push_error("missing" + str(get_path()))
		return
	activated = true
	GameManager.last_save_point = global_position
	GameManager.last_level = owner.scene_file_path
	print(GameManager.last_level, "and ", GameManager.last_save_point)
	
	if is_instance_valid(prompt):
		prompt.visible = false
	sprite.play("activated")
