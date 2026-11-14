extends Area2D

@onready var sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

func _ready() -> void:
	# Ensure the chest animation doesn't loop infinitely
	if sprite.sprite_frames.has_animation("chest"):
		sprite.sprite_frames.set_animation_loop("chest", false)
	
	# Connect the body_entered signal via code so it triggers when the player touches/jumps on it
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if the player entered the chest area (e.g. landing on it or touching it)
	if body.name == "CharacterBody2D" or body.is_in_group("Player"):
		if sprite.sprite_frames.has_animation("chest"):
			sprite.play("chest")
