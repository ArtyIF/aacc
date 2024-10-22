## An AACC car plugin that applies simple wheel suspension to the car. The
## wheels don't apply any torque force, other plugins are used for that instead.
class_name AACCPluginSuspension extends AACCPlugin

@export_group("Transforms")
## The transforms of wheels that have the properties listed below. Also stores
## per-wheel information.
@export var wheels: Array[AACCSuspensionWheel] = []

@export_group("Shape")
## The radius of wheels. Half of the wheels' size.
@export var wheel_radius: float = 0.3
## The extra radius of wheels to make the car stick to the ground more.
@export var buffer_radius: float = 0.1
## The width of wheels.
## 
## AACC's wheels currently use 2 raycasts for the wheels.
@export var wheel_width: float = 0.3

@export_group("Suspension")
## The maximum length of the suspensions.
## [br][br]
## If the suspension length gets exceeded (because of the
## [member buffer_radius]), the suspension starts working in reverse, pulling
## the car to the ground instead of pushing it away from it. This can be useful
## to make the car stick to the ground better.
@export var suspension_length: float = 0.1
## The spring force the suspensions apply.
@export var suspension_spring: float = 3000.0
## The damper applied to the spring force the suspensions apply so they aren't
## too springy and out of control.
@export var suspension_damper: float = 300.0


func _ready():
	for wheel in wheels:
		wheel.initialize(self)


func _physics_process(delta: float):
	for wheel in wheels:
		wheel.calculate_force()
		if wheel.is_colliding:
			# spring
			var force = wheel.compression * suspension_spring

			# damper
			var compression_delta: float = (wheel.compression - wheel.last_compression) / delta
			force += compression_delta * suspension_damper
			wheel.set_last_compression()
			
			# aligning
			force *= wheel.collision_normal.dot(parent_car.global_transform.basis.y)
			
			var global_parent_com: Vector3 = parent_car.to_global(Vector3.ZERO)
			parent_car.add_force(wheel.collision_normal * force, wheel.collision_point - global_parent_com)
