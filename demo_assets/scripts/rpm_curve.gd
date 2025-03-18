extends Control

func _draw() -> void:
	var curve: Curve = AACCGlobal.car.get_param(&"rpm_curve")
	if not curve:
		draw_string(ThemeDB.fallback_font, Vector2(0.0, size.y), "No RPM curve!")
		return

	var points: PackedVector2Array = []
	var colors: PackedColorArray = []
	var rpm_max: float = AACCGlobal.car.get_param(&"rpm_max", 1.0)
	for i in range(0, curve.bake_resolution + 1):
		var point_x: float = float(i) / curve.bake_resolution
		points.append(Vector2(point_x * size.x, (1.0 - curve.sample_baked(point_x)) * size.y))
		colors.append(Color.WHITE if point_x < rpm_max else Color.RED)
	draw_polyline_colors(points, colors, 0.5, true)

	var rpm_curve_peak: float = AACCGlobal.car.get_param(&"rpm_curve_peak", 1.0)
	draw_polyline([Vector2(rpm_curve_peak * size.x, 0.0), Vector2(rpm_curve_peak * size.x, size.y)], Color.GREEN)
