## TODO: documentation
class_name CarBrakeSquealSound extends AudioStreamPlayer3D

@onready var car: Car = get_node("..")

var smoothed_brake_amount: SmoothedFloat = SmoothedFloat.new(0.0, 8.0, 4.0)

func _physics_process(delta: float) -> void:
	var target_value: float = (car.input_forward if car.is_reversing() else car.input_backward) * car.ground_coefficient
	# TODO: account velocity too
	smoothed_brake_amount.advance_to(target_value, delta)
	volume_db = linear_to_db(lerp(0.0, 1.0, smoothed_brake_amount.get_current_value()))

	if is_inf(volume_db):
		volume_db = -80.0
	if volume_db >= -60.0 and not playing:
		play(randf_range(0.0, stream.get_length()))
	elif volume_db < -60.0 and playing:
		stop()
