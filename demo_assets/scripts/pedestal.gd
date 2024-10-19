extends AnimatableBody3D

@export var lowered: bool = false
var _position: SmoothedFloat = SmoothedFloat.new(1.75)

func _physics_process(delta: float) -> void:
	_position.advance_to(-0.2 if lowered else 1.75, delta)
	position.y = _position.get_current_value()
