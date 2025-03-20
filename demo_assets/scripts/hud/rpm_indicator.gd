extends Control

func _draw() -> void:
	if not AACCGlobal.car.has_meta(&"rpm_curve"):
		draw_string(ThemeDB.fallback_font, Vector2(0.0, size.y), "No RPM curve!")
	else:
		var curve: Curve = AACCGlobal.car.get_meta(&"rpm_curve")

		var points_current: PackedVector2Array = []
		for i in range(0, curve.bake_resolution + 1):
			var point_x: float = float(i) / curve.bake_resolution
			points_current.append(Vector2(point_x * size.x, (1.0 - curve.sample_baked(point_x)) * size.y))
		draw_polyline(points_current, Color.WHITE, 1.0, true)

		var gear_current: float = float(AACCGlobal.car.get_meta(&"gear_current", 0))
		if not AACCGlobal.car.get_meta(&"gear_switching", false):
			if AACCGlobal.car.get_meta(&"ground_coefficient", 0.0) > 0.0 and gear_current >= 0 and gear_current < AACCGlobal.car.get_meta(&"gear_count", 0):
				var current_next_ratio: float = max(gear_current, 1.0) / max(gear_current + 1, 1.0)
				if current_next_ratio < 1.0:
					var points_next: PackedVector2Array = []
					for i in range(0, curve.bake_resolution + 1):
						var point_x: float = float(i) * current_next_ratio / curve.bake_resolution
						var point_y: float = curve.sample_baked(point_x) * current_next_ratio
						points_next.append(Vector2(point_x * size.x / current_next_ratio, (1.0 - point_y) * size.y))
					draw_polyline(points_next, Color.YELLOW, 1.0, true)

			if (gear_current >= 0 and gear_current < AACCGlobal.car.get_meta(&"gear_count", 0)) or is_zero_approx(AACCGlobal.car.get_meta(&"ground_coefficient", 0.0)):
				var gear_perfect_switch: float = AACCGlobal.car.get_meta(&"gear_perfect_switch", 1.0)
				draw_line(Vector2(gear_perfect_switch * size.x, 0.0), Vector2(gear_perfect_switch * size.x, size.y), Color(Color.GREEN, 0.5), 2.0)

	var rpm_ratio: float = AACCGlobal.car.get_meta(&"rpm_ratio", 1.0)
	draw_rect(Rect2(0.0, 0.0, rpm_ratio * size.x, size.y), Color(Color.WHITE, 0.5))

	var rpm_max: float = AACCGlobal.car.get_meta(&"rpm_max", 1.0)
	draw_rect(Rect2(rpm_max * size.x, 0.0, (1.0 - rpm_max) * size.x, size.y), Color(Color.RED, 0.5))

func _process(_delta: float) -> void:
	queue_redraw()
