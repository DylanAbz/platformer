extends CharacterBody3D

@export var speed: float = 6.0
@export var acceleration: float = 20.0
@export var friction: float = 25.0
@export var jump_velocity: float = 9.0
@export var gravity: float = 25.0
@export var jump_anim_speed: float = 2.6  # accélère l'anim de saut pour qu'elle colle au saut physique
@export var roll_anim_speed: float = 1.5  # vitesse de la roulade d'atterrissage

@onready var model: Node3D = $Model
@onready var anim: AnimationPlayer = $Model/AnimationPlayer

var locked_z: float
var input_direction: float = 0.0
var was_on_floor: bool = true
var is_rolling: bool = false

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
	update_animation()

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

func update_animation() -> void:
	var on_floor := is_on_floor()
	var just_landed := on_floor and not was_on_floor
	was_on_floor = on_floor

	# atterrissage après un vol -> roulade
	if just_landed:
		is_rolling = true
		anim.play("roll", -1, roll_anim_speed)
		return

	# laisse la roulade se terminer (annulée si Homer resaute)
	if is_rolling:
		if not on_floor:
			is_rolling = false
		elif anim.current_animation == "roll" and anim.is_playing():
			return
		else:
			is_rolling = false

	# danse : touche B maintenue, au sol et immobile
	if on_floor and Input.is_action_pressed("dance") and absf(velocity.x) < 0.1:
		if anim.current_animation != "dance":
			anim.play("dance")
		return

	# en l'air -> "jump", sinon "run" s'il avance, sinon "idle"
	var target: String
	if not on_floor:
		target = "jump"
	elif absf(velocity.x) > 0.1:
		target = "run"
	else:
		target = "idle"
	if anim.current_animation != target:
		if target == "jump":
			anim.play("jump", -1, jump_anim_speed)  # saut joué plus vite
		else:
			anim.play(target)
