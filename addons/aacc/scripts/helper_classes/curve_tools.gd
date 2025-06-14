class_name AACCCurveTools

static func get_curve_samples(curve: Curve, ratio: float = 1.0, max_x: float = 1.0) -> PackedVector2Array:
	var list: PackedVector2Array = []

	for i in range(0, curve.bake_resolution + 1):
		var point_x: float = float(i) / curve.bake_resolution
		if point_x > max_x:
			break
		var point_y: float = curve.sample_baked(point_x * ratio) * ratio
		list.append(Vector2(point_x, point_y))

	return list

static func get_curve_samples_intersection(samples_1: PackedVector2Array, samples_2: PackedVector2Array) -> float:
	var intersection: float = 0.0
	var diff_sign_prev: float = 0.0

	for i in range(0, min(len(samples_1), len(samples_2))):
		var point_1: Vector2 = samples_1[i]
		var point_2: Vector2 = samples_2[i]

		var diff_sign: float = sign(point_2.y - point_1.y)
		if diff_sign != diff_sign_prev and not is_zero_approx(diff_sign):
			intersection = point_1.x
		diff_sign_prev = diff_sign

	return intersection

# TODO: move somewhere else?
static func get_gear_perfect_shift_up(gear_current: int, rpm_curve: Curve) -> float:
	var perfect: float = 0.0

	var rpm_curve_samples_current: PackedVector2Array = get_curve_samples(rpm_curve)

	if gear_current > -1:
		var current_next_ratio: float = maxf(gear_current, 1.0) / maxf(gear_current + 1, 1.0)
		var rpm_curve_samples_next: PackedVector2Array = get_curve_samples(rpm_curve, current_next_ratio)
		perfect = get_curve_samples_intersection(rpm_curve_samples_current, rpm_curve_samples_next)
	return perfect

static func get_gear_perfect_shift_down(gear_current: int, rpm_curve: Curve) -> float:
	var perfect: float = 0.0

	var rpm_curve_samples_current: PackedVector2Array = get_curve_samples(rpm_curve)

	if gear_current > 1:
		var current_prev_ratio: float = maxf(gear_current, 1.0) / maxf(gear_current - 1, 1.0)
		var rpm_curve_samples_prev: PackedVector2Array = get_curve_samples(rpm_curve, current_prev_ratio, 1.0 / current_prev_ratio)
		perfect = get_curve_samples_intersection(rpm_curve_samples_current, rpm_curve_samples_prev)
	return perfect
