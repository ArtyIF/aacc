class_name ProceduralCurve extends Resource

@export var left_value: float = 0.0
@export var right_value: float = 1.0
@export var max_input: float = 1.0
@export_exp_easing var input_curve: float = 1.0

func sample(input: float) -> float:
	return lerp(left_value, right_value, ease(clamp(input / max_input, 0.0, 1.0), input_curve))
