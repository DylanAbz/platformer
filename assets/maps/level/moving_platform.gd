extends AnimatableBody3D

@export var vitesse  : float = 3.0
@export var distance : float = 6.0
@export var reversed : bool = false

var _origine    : Vector3
var _direction  : float = 1.0
var _reversedValue : float = 1.0

func _ready() -> void:
	_origine = global_position
	if reversed:
		_reversedValue = -1.0

func _physics_process(delta: float) -> void:
	global_position.x += vitesse * _direction * delta

	var d := global_position.x - _origine.x

	if d > distance:
		global_position.x = _origine.x + distance  # recale à la borne +
		_direction = -1.0 * _reversedValue                          # force vers -Z
	elif d < -distance:
		global_position.x = _origine.x - distance  # recale à la borne -
		_direction = 1.0 * _reversedValue                         # force vers +Z
