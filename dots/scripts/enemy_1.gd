extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_ray: RayCast2D = $WallRayCheck
@onready var ledge_ray: RayCast2D = $LedgeRayCheck
var health: int = 2
var knock_dir: int = 1
var damaged = false
var speed: float = 30.0

var stop: bool = false

var direction: int = 1

func _ready():
	sprite.play("walk")
	sprite.flip_h = (direction > 0)
	
	if stop:
		return

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_on_wall() or (wall_ray.is_colliding() or not ledge_ray.is_colliding()) && not damaged:
		flip_direction()
	if not damaged:
		velocity.x = direction * speed
	
	move_and_slide()
	


func flip_direction() -> void:
	if not stop:
		direction *= -1
		sprite.flip_h = (direction > 0)
		wall_ray.scale.x = -wall_ray.scale.x
		wall_ray.position.x = -wall_ray.position.x
		ledge_ray.scale.x = -ledge_ray.scale.x
		ledge_ray.position.x = -ledge_ray.position.x
	



func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack"):
		if GameManager.player_x > global_position.x:
			knock_dir = 1
		else: 
			knock_dir = -1
		damaged = true
		sprite.play("hurt")
		health -= 1
		print("enemy health:", health)
		velocity.y = -50
		velocity.x = -50 * knock_dir
		await get_tree().create_timer(0.25).timeout
		damaged = false
		sprite.play("walk")
	
	if area.is_in_group("normal_hazard"):
		health = 0
	
	if health <= 0:
		stop = true
		speed = 1
		sprite.play("death")
		$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)
		await $AnimatedSprite2D.animation_finished
		queue_free()
		
