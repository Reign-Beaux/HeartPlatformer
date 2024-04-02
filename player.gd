extends CharacterBody2D

@export var movement_data: PlayerMovementData

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer

var air_jump = false
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	var horizontal_input := Input.get_axis("ui_left", "ui_right")
	apply_gravity(delta)
	handle_jump()
	handle_acceleration(horizontal_input, delta)
	handle_air_acceleration(horizontal_input, delta)
	apply_friction(horizontal_input, delta)
	apply_air_resistence(horizontal_input, delta)
	update_animations(horizontal_input)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * movement_data.GRAVITY_SCALE * delta

func handle_jump() -> void:
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if  Input.is_action_just_pressed("ui_accept"):
			velocity.y = movement_data.JUMP_VELOCITY
	if not is_on_floor():
		if Input.is_action_just_released("ui_accept") and velocity.y < movement_data.JUMP_VELOCITY / 2:
			velocity.y = movement_data.JUMP_VELOCITY / 2

func handle_acceleration(horizontal_input: float, delta: float):
	if not is_on_floor():
		return
	
	if horizontal_input:
		velocity.x = move_toward(
			velocity.x,
			horizontal_input * movement_data.SPEED,
			movement_data.ACCELERATION * delta)

func handle_air_acceleration(horizontal_input: float, delta: float):
	if is_on_floor():
		return
	
	if horizontal_input != 0:
		velocity.x = move_toward(
			velocity.x,
			movement_data.SPEED * horizontal_input,
			movement_data.AIR_ACCELERATION * delta)

func apply_friction(horizontal_input: float, delta: float):
	if horizontal_input == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.FRICTION * delta)

func apply_air_resistence(horizontal_input: float, delta: float):
	if horizontal_input == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.AIR_RESISTENCE * delta)

func update_animations(horizontal_input: float) -> void:
	if horizontal_input != 0:
		animated_sprite_2d.flip_h = horizontal_input < 0
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")
