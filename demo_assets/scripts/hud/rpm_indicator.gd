extends Control

func remap_points(points: PackedVector2Array) -> PackedVector2Array:
	for i in range(len(points)):
		var point: Vector2 = points[i]
		points[i] = Vector2(point.x * size.x, (1.0 - point.y) * size.y)
	return points

func _draw() -> void:
	if not AACCGlobal.car: return

	var gear_perfect_shift_up: float = 1.0
	var gear_perfect_shift_down: float = 0.0

	var points_current: PackedVector2Array = []
	var points_next: PackedVector2Array = []
	var points_prev: PackedVector2Array = []
	if not AACCGlobal.car.has_meta(&"rpm_curve"):
		draw_string(ThemeDB.fallback_font, Vector2(0.0, size.y), "No RPM curve!")
	else:
		var rpm_curve: Curve = AACCGlobal.car.get_meta(&"rpm_curve")
		var gear_current: float = float(AACCGlobal.car.get_meta(&"gear_current", 0))
		points_current = remap_points(AACCCurveTools.get_curve_samples(rpm_curve))

		if not AACCGlobal.car.get_meta(&"gear_switching", false):
			if AACCGlobal.car.get_meta(&"ground_coefficient", 0.0) > 0.0:
				if gear_current >= 0 and gear_current < AACCGlobal.car.get_meta(&"gearbox_gear_count", 0):
					var current_next_ratio: float = max(gear_current, 1.0) / max(gear_current + 1, 1.0)
					if current_next_ratio < 1.0:
						points_next = remap_points(AACCCurveTools.get_curve_samples(rpm_curve, current_next_ratio))

				if gear_current > 1 and gear_current <= AACCGlobal.car.get_meta(&"gearbox_gear_count", 0):
					var current_prev_ratio: float = max(gear_current, 1.0) / max(gear_current - 1, 1.0)
					if current_prev_ratio > 1.0:
						points_prev = remap_points(AACCCurveTools.get_curve_samples(rpm_curve, current_prev_ratio))

				if (gear_current > 0 and gear_current < AACCGlobal.car.get_meta(&"gearbox_gear_count", 0)):
					gear_perfect_shift_up = AACCCurveTools.get_gear_perfect_shift_up(AACCGlobal.car)

				if (gear_current > 1 and gear_current <= AACCGlobal.car.get_meta(&"gearbox_gear_count", 0)):
					gear_perfect_shift_down = AACCCurveTools.get_gear_perfect_shift_down(AACCGlobal.car)

	var rpm_ratio: float = AACCGlobal.car.get_meta(&"rpm_ratio", 0.0)
	var rpm_bar_color: Color = Color.WHITE
	if rpm_ratio <= gear_perfect_shift_down:
		rpm_bar_color = Color.RED
	elif rpm_ratio >= gear_perfect_shift_up:
		rpm_bar_color = Color.GREEN
	draw_rect(Rect2(0.0, 0.0, rpm_ratio * size.x, size.y), Color(rpm_bar_color, 0.75))

	var rpm_max: float = AACCGlobal.car.get_meta(&"rpm_max", 1.0)
	draw_rect(Rect2(rpm_max * size.x, 0.0, (1.0 - rpm_max) * size.x, size.y), Color(Color.RED, 0.5))

	if not points_current.is_empty():
		draw_polyline(points_current, Color.WHITE, 1.0, true)
	if not points_next.is_empty():
		draw_polyline(points_next, Color.GREEN, 1.0, true)
	if not points_prev.is_empty():
		draw_polyline(points_prev, Color.RED, 1.0, true)

func _process(_delta: float) -> void:
	queue_redraw()
