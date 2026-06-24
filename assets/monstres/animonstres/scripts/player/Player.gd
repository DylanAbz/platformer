extends CharacterBody3D

@export var speed: float = 6.0
@export var acceleration: float = 20.0
@export var friction: float = 25.0
@export var jump_velocity: float = 9.0
@export var gravity: float = 25.0

@onready var model: Node3D = $Model

var locked_z: float
var input_direction: float = 0.0

func _ready() -> void:
	locked_z = global_position.z

func _physics_process(delta: float) -> void:
	read_input()
	apply_horizontal_movement(delta)
	apply_gravity(delta)
	apply_jump()
	lock_depth()
	move_and_slide()
	force_depth_position()
	rotate_model()

func read_input() -> void:
	input_direction = 0.0

	if Input.is_action_pressed("move_left"):
		input_direction -= 1.0

	if Input.is_action_pressed("move_right"):
		input_direction += 1.0

func apply_horizontal_movement(delta: float) -> void:
	var target_speed := input_direction * speed

	if input_direction != 0:
		velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if velocity.y < 0:
			velocity.y = 0.0

func apply_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

func lock_depth() -> void:
	velocity.z = 0.0

func force_depth_position() -> void:
	global_position.z = locked_z

func rotate_model() -> void:
	if input_direction > 0:
		model.rotation.y = deg_to_rad(90)
	elif input_direction < 0:
		model.rotation.y = deg_to_rad(-90)
