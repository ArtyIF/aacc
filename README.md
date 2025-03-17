# Arty's Arcadey Car Controller

A very work-in-progress car controller. Includes a very basic demo scene and
two cars (no way to easily switch between them).

**NOTE**: please pay attention to the `attribution.txt` files in the
`addons/aacc` folder! Some files' licenses require attribution if you're going
to use them!

**NOTE**: most of the work is currently being done in the
[`rewrite`](https://github.com/ArtyIF/aacc/tree/rewrite) branch! That branch
rewrites AACC from scratch with a plugin-based system. It's not complete yet,
but once it's ready, it'll be merged into this branch. `rewrite` is not compatible
with this branch, and there won't be an easy way to port cars from the old version!

## Dependencies
- Godot 4.4+ (tested on rc1, some changes may cause the project to break on
  earlier versions)
- - For the Godot 4.3 version, see the `godot-4.3` tag
- - For Godot 4.4.dev6 and earlier, download [Godot Jolt](https://github.com/godot-jolt/godot-jolt)
	for best results.
- [Hydraboo's TrailRenderer](https://github.com/Hyrdaboo/TrailRenderer)
  for skid trails
- Blender 3.5 or later (3.0-3.4 might also work) for the demo scene

## Demo Scene controls
- W/S (keyboard), RT/LT (gamepad) - gas and brake/reverse
- A/D (keyboard), Left Stick Left/Right (gamepad) - steer
- Space (keyboard), X (Xbox gamepad), Cross (DualShock), Y (Switch gamepad) -
  handbrake
- R (keyboard), Back/Squares (Xbox gamepad), Select/Options(?) (DualShock),
  minus (Switch gamepad) - reset
- C (keyboard), Right Stick Click (gamepad) - toggle hood camera
