extends Control

func _draw() -> void:
	var curve: Curve = AACCGlobal.car.get_param(&"rpm_curve")
	if not curve:
		draw_string(ThemeDB.fallback_font, Vector2(0.0, size.y), "No RPM curve!")
		return

	var points: PackedVector2Array = []
	for i in range(0, curve.bake_resolution + 1):
		var point_x: float = float(i) / curve.bake_resolution
		points.append(Vector2(point_x * size.x, (1.0 - curve.sample_baked(point_x)) * size.y))
	draw_polyline(points, Color.BLACK, 2.0, true)
	draw_polyline(points, Color.WHITE, 1.0, true)

	var rpm_curve_peak: float = AACCGlobal.car.get_param(&"rpm_curve_peak", 1.0)
	draw_line(Vector2(rpm_curve_peak * size.x, 0.0), Vector2(rpm_curve_peak * size.x, size.y), Color(Color.GREEN, 0.5), 2.0)

	var rpm_max: float = AACCGlobal.car.get_param(&"rpm_max", 1.0)
	draw_rect(Rect2(rpm_max * size.x, 0.0, (1.0 - rpm_max) * size.x, size.y), Color(Color.RED, 0.5))

func _process(_delta: float) -> void:
	queue_redraw()
