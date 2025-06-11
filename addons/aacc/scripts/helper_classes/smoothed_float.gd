## A class to help smoothly move floating point values over time.
## 
## The value is moved linearly, similar to the
## [method @GlobalScope.move_toward] method.
class_name SmoothedFloat

## The speed the current value advances to the target value with when
## [method advance_to] is called and the target value is above the current one.
var speed_up: float = 0.0
## The speed the current value advances to the target value with when
## [method advance_to] is called and the target value is below the current one.
var speed_down: float = 0.0

var _value: float = 0.0

## Advances the current value to [param target_value] by [member speed_up] or
## [member speed_down]. Optionally, [param speed_multiplier] can be assigned.
## Usually called in [method Node._process] or [method Node._physics_process],
## with [param speed_multiplier] being set to the delta value.
func advance_to(target_value: float, speed_multiplier: float = 1.0) -> void:
	if target_value < _value:
		_value = move_toward(_value, target_value, speed_down * speed_multiplier)
	else:
		_value = move_toward(_value, target_value, speed_up * speed_multiplier)

## Returns the current value.
## TODO: change to property
func get_value() -> float:
	return _value

## Forces the current value to [param new_value].
## TODO: change to property
func force_current_value(new_value: float) -> void:
	_value = new_value

func _init(start_value: float = 0.0, speed_up: float = 1.0, speed_down: float = -1.0) -> void:
	self._value = start_value
	self.speed_up = speed_up
	if speed_down > 0:
		self.speed_down = speed_down
	else:
		self.speed_down = speed_up

func _to_string() -> String:
	return "%f (speed up = %s, speed down = %s)" % [_value, speed_up, speed_down]
