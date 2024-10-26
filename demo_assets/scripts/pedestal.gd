extends AnimatableBody3D

@export var lowered: bool = false
var _position: SmoothedFloat = SmoothedFloat.new(1.95)

func _physics_process(delta: float) -> void:
	_position.advance_to(0.0 if lowered else 1.95, delta)
	position.y = _position.get_current_value()
