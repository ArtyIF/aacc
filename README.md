# Arty's Arcadey Car Controller

A very work-in-progress car controller. Includes a very basic demo.

This branch makes AACC plugin-based. It's very work-in-progress. If you need
a car controller now, check out the `master` branch. You will still need to work
on it a bit, however.

**NOTE**: please pay attention to the `attribution.txt` files in the
`addons/aacc` folder! Some files' licenses require attribution if you're going
to use them!

## Dependencies
- Godot 4.4+ (tested on rc2, some changes may cause the project to break on
  earlier versions)
- - For Godot 4.4.dev6 and earlier, download [Godot Jolt](https://github.com/godot-jolt/godot-jolt)
	for best results.
- [Hydraboo's TrailRenderer](https://github.com/Hyrdaboo/TrailRenderer)
  for skid trails
- Blender 3.5 or later (3.0-3.4 might also work) for the demo

## Demo Scene controls
- W/S (keyboard), RT/LT (gamepad) - gas and brake/reverse
- A/D (keyboard), Left Stick Left/Right (gamepad) - steer
- Space (keyboard), X (Xbox gamepad), Cross (DualShock), Y (Switch gamepad) -
  handbrake
