extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -600.0

@onready var sprite_file = $AnimatedSprite2D
@onready var attack_area = $AttackArea # Make sure your player has an Area2D child named AttackArea

var is_jumping = false
var is_reborning = false
var is_attacking = false
var start_position: Vector2

func _ready() -> void:
	start_position = global_position
	# Force animations not to loop via code
	sprite_file.sprite_frames.set_animation_loop("reborn", false)
	if sprite_file.sprite_frames.has_animation("attack"):
		sprite_file.sprite_frames.set_animation_loop("attack", false)
	sprite_file.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += 1.7 * get_gravity() * delta
		
	# Handle attack input (Up Arrow)
	if Input.is_action_just_pressed("ui_up") and is_on_floor() and not is_attacking and not is_reborning:
		perform_attack()
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_attacking and not is_reborning:
		velocity.y = JUMP_VELOCITY
		is_jumping = true
	elif is_on_floor():
		is_jumping = false


	# Get the input direction and handle movement/deceleration.
	if is_attacking:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
			if not is_reborning:
				sprite_file.play("running")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if not is_reborning:
				sprite_file.play("static")
				
		if direction == -1:
			sprite_file.flip_h = true
		elif direction == 1:
			sprite_file.flip_h = false
			
	handle_animations()
	move_and_slide()
	
	# Check if the character falls past the Y threshold
	if global_position.y > 1000:
		respawn()
	
func handle_animations() -> void:
	if is_reborning or is_attacking:
		return
	if is_jumping:
		sprite_file.play("Jump-up")

func perform_attack() -> void:
	is_attacking = true
	sprite_file.play("attack")
	
	# Check for any bodies in attack range that have a take_damage function (like chests/walls)
	if attack_area:
		for body in attack_area.get_overlapping_bodies():
			if body.has_method("take_damage"):
				body.take_damage(1)

func respawn() -> void:
	global_position = start_position
	velocity = Vector2.ZERO
	is_reborning = true
	sprite_file.play("reborn")

func _on_animation_finished() -> void:
	if sprite_file.animation == "reborn":
		is_reborning = false
	elif sprite_file.animation == "attack":
		is_attacking = false
