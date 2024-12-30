extends Node

var current_car: Car
var current_car_input: CarInput
var current_shadow_color: Color = Color.BLACK
var current_shadow_color_amount: float = 0.0

enum BurnoutParticlesQuality {
	OFF = 0, # disabled
	VERY_LOW = 1, # unlit, no proximity fade
	LOW = 2, # vertex lit, no shadow, no proximity fade (highest working for compatibility as of now)
	MEDIUM = 3, # vertex lit, no shadow, proximity fade
	HIGH = 4, # vertex lit, shadow, proximity fade
	ULTRA = 5 # pixel lit, shadow, proximity fade
}
var current_burnout_particles_quality: BurnoutParticlesQuality = BurnoutParticlesQuality.LOW
