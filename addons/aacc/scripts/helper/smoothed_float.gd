## A basic class to smoothly move floating point values over time.
## 
## The value is moved linearly, similar to the
## [method @GlobalScope.move_toward] method.
class_name SmoothedFloat

## The speed the current value advances to the target value with when
## [method advance_to] is called.
var speed: float = 0.0

var _current_value: float = 0.0


## Advances the current value to [param target_value] by [member speed].
## Optionally, [param speed_multiplier] can be assigned.
## Usually called in [method Node._process] or [method Node._physics_process],
## with [param speed_multiplier] being set to the delta value.
func advance_to(target_value: float, speed_multiplier: float = 1.0):
	_current_value = move_toward(_current_value, target_value, speed * speed_multiplier)


## Returns the current value.
func get_current_value() -> float:
	return _current_value


## Forces the current value to [param new_value].
func force_current_value(new_value: float):
	_current_value = new_value


func _init(start_value: float = 0.0, speed: float = 1.0):
	self._current_value = start_value
	self.speed = speed
