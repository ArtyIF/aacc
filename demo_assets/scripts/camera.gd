extends Camera3D
@export var car: Car
var _smoothed_direction: Vector3 = Vector3.FORWARD
var _smoothed_position: Vector3 = -Vector3.FORWARD

func _ready() -> void:
	pass # Replace with function body.

# TODO: use _process and implement smoothing for cars
func _physics_process(delta: float) -> void:
	_smoothed_direction = _smoothed_direction.slerp(Plane.PLANE_XZ.project(car.global_basis.z), delta * 10.0)
	_smoothed_position = _smoothed_position.lerp(car.global_position + (_smoothed_direction * 4.0) + (Vector3.UP * 2.0), delta * 30.0)
	global_position = _smoothed_position
	global_basis = Basis.looking_at(-_smoothed_direction)
