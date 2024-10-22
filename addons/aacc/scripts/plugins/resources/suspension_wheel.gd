class_name AACCSuspensionWheel extends Resource

@export var position: Vector3 = Vector3.ZERO
@export_range(-360.0, 360.0, 0.1, "radians") var rotation_degrees: float = 0.0

#== NODES ==#
var raycast_instance_outer: RayCast3D
var raycast_instance_inner: RayCast3D
var owner: AACCPluginSuspension

#== COMPRESSION ==#
var compression: float = 0.0
var last_compression: float = 0.0
var last_compression_set: bool = false

#== EXTERNAL ==#
var is_colliding: bool = false
var collision_point: Vector3
var collision_normal: Vector3
var distance: float

func initialize(owner: AACCPluginSuspension):
	self.owner = owner

	raycast_instance_outer = RayCast3D.new()
	raycast_instance_outer.target_position = (Vector3.DOWN * (owner.wheel_radius + owner.suspension_length + owner.buffer_radius))
	raycast_instance_outer.enabled = true
	raycast_instance_outer.hit_from_inside = false
	raycast_instance_outer.hit_back_faces = false
	raycast_instance_outer.collision_mask = 1
	raycast_instance_outer.process_physics_priority = -1000
	raycast_instance_outer.transform = owner.transform.translated_local(
		position + (Vector3.RIGHT * owner.wheel_width).rotated(Vector3.UP, rotation_degrees)
	)
	owner.add_child(raycast_instance_outer)

	raycast_instance_inner = RayCast3D.new()
	raycast_instance_inner.target_position = (
		Vector3.DOWN * (owner.wheel_radius + owner.suspension_length + owner.buffer_radius)
	)
	raycast_instance_inner.enabled = true
	raycast_instance_inner.hit_from_inside = false
	raycast_instance_inner.hit_back_faces = false
	raycast_instance_inner.collision_mask = 1
	raycast_instance_inner.process_physics_priority = -1000
	raycast_instance_inner.transform = owner.transform.translated_local(position)
	owner.add_child(raycast_instance_inner)

func reset():
	raycast_instance_outer.queue_free()
	raycast_instance_outer = null
	raycast_instance_inner.queue_free()
	raycast_instance_inner = null

func calculate_force():
	if raycast_instance_outer.is_colliding() or raycast_instance_inner.is_colliding():
		is_colliding = true

		var distance_outer = raycast_instance_outer.global_position.distance_to(
			raycast_instance_outer.get_collision_point()
		)
		var distance_inner = raycast_instance_inner.global_position.distance_to(
			raycast_instance_inner.get_collision_point()
		)

		if raycast_instance_outer.is_colliding() and raycast_instance_inner.is_colliding():
			collision_point = (
				raycast_instance_outer.get_collision_point().
					lerp(raycast_instance_inner.get_collision_point(), 0.5)
			)
			collision_normal = (
				raycast_instance_outer.get_collision_normal().
					slerp(raycast_instance_inner.get_collision_normal(), 0.5)
			)
			distance = lerp(distance_outer, distance_inner, 0.5)
		else:
			# TODO: DRY
			collision_point = (
				raycast_instance_outer.get_collision_point()
				if raycast_instance_outer.is_colliding()
				else raycast_instance_inner.get_collision_point()
			)
			collision_normal = (
				raycast_instance_outer.get_collision_normal()
				if raycast_instance_outer.is_colliding()
				else raycast_instance_inner.get_collision_normal()
			)
			distance = distance_outer if raycast_instance_outer.is_colliding() else distance_inner

		compression = 1.0 - ((distance - owner.wheel_radius) / owner.suspension_length)
		if not last_compression_set:
			last_compression = compression
			last_compression_set = true
	else:
		is_colliding = false
		compression = 0.0
		last_compression = 0.0

func set_last_compression():
	last_compression = compression
