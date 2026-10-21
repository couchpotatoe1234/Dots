extends Area2D

@onready var prompt: Label = get_node_or_null("Label")
@onready var sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

var player_in_range: bool = false
var activated: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("--------checkpoint debug----------")
	print("node", get_path())
	print("sprite", get_node_or_null("AnimatedSprite2D"))
	print("label", get_node_or_null("Label"))
	
	if sprite == null:
		push_error("missing")
		return
	
	sprite.play("notactivated")
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
		print("player entered")
		player_in_range = true
		
		if not activated and is_instance_valid(prompt):
			prompt.show()
			
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		
		if is_instance_valid(prompt):
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
	sprite.play("activated")
