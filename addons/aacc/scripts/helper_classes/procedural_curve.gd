## A class to procedurally generate a simple two-point curve using the
## [method @GlobalScope.ease] method.
class_name ProceduralCurve extends Resource

## The value at the input of [code]0[/code].
@export var left_value: float = 0.0
## The value at the input of [member max_input].
@export var right_value: float = 1.0
## The maximum input. Any input below [code]0[/code] and above this value gets
## clamped.
@export var max_input: float = 1.0
## The curve applied to the input. See the [param curve] parameter of
## [method @GlobalScope.ease] for details.
@export_exp_easing var input_curve: float = 1.0

## Sample the procedural curve at a specified [param input].
func sample(input: float) -> float:
	return lerp(left_value, right_value, ease(clamp(input / max_input, 0.0, 1.0), input_curve))
