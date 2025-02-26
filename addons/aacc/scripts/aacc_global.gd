extends Node

var current_car: Car
var current_car_input: CarInput
var current_shadow_intensity: float = 0.0

enum BurnoutParticlesQuality {
	OFF = 0, # disabled
	VERY_LOW = 1, # unlit, no proximity fade
	LOW = 2, # vertex lit, no shadow, no proximity fade (highest working for compatibility as of now)
	MEDIUM = 3, # vertex lit, no shadow, proximity fade
	HIGH = 4, # vertex lit, shadow, proximity fade
	ULTRA = 5 # pixel lit, shadow, proximity fade
}
var current_burnout_particles_quality: BurnoutParticlesQuality = BurnoutParticlesQuality.LOW

enum SoundQuality {
	OFF = 0,
	CURRENT_ONLY = 1,
	ON = 2
}
var current_sound_qualities: Dictionary[StringName, SoundQuality] = {
	"Engine" = SoundQuality.ON,
	"TireScreech" = SoundQuality.ON,
	"Scrape" = SoundQuality.ON,
	"Collision" = SoundQuality.ON,
	"BrakeSqueal" = SoundQuality.ON,
	"TireRoll" = SoundQuality.ON,
}

var current_emit_sparks: bool = true

func can_play(sound_type: StringName, car: Car) -> bool:
	return (
		current_sound_qualities[sound_type] == SoundQuality.ON or
		(current_sound_qualities[sound_type] == SoundQuality.CURRENT_ONLY and car == current_car)
	)
