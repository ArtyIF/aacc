# Arty's Arcadey Car Controller

A very work-in-progress car controller. Includes a very basic demo scene and
two cars (no way to easily switch between them).

**NOTE**: please pay attention to the `attribution.txt` files in the
`addons/aacc` folder! Some files' licenses require attribution if you're going
to use them!

**NOTE**: the project is semi-abandoned! Changes are still being made, but
only as necessary for the game I'm currently working on, No Downforce. Once
I'm done with that, I'm probably going to resume working fully on this project.

## Dependencies
- Godot 4.4+ (tested on beta1, some changes may cause the project to break on
  earlier versions)
- - For the Godot 4.3 version, see 3e0cc4987715be7c1ad1e39ebd9c060fab6e6751
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
