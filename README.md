# Arty's Arcadey Car Controller

A very work-in-progress car controller. Includes a very basic demo scene and
two cars (no way to easily switch between them).

**NOTE**: please pay attention to the `attribution.txt` files in the
`addons/aacc` folder! Some files' licenses require attribution if you're going
to use them!

## Dependencies
- Godot 4.4+ (tested on dev5)
- - For the Godot 4.3 version, see 3e0cc4987715be7c1ad1e39ebd9c060fab6e6751
- [lawnjelly's smoothing addon](https://github.com/lawnjelly/smoothing-addon/tree/4.x)
  for physics interpolation (Godot 4.4's interpolation is currently broken?)
- [Hydraboo's TrailRenderer](https://github.com/Hyrdaboo/TrailRenderer)
  for skid trails
- Blender 3.5 or later (3.0-3.4 might also work) for the demo scene
- - **NOTE**: Blender 4.3 currently has an issue with exporting files as GLTF,
	which is what Godot asks Blender to do when importing a blend file! Use
	Blender 4.2 LTS in the meantime. The issue will probably get fixed by 4.3.1.

## Demo Scene controls
- W/S (keyboard), RT/LT (gamepad) - gas and brake/reverse
- A/D (keyboard), Left Stick Left/Right (gamepad) - steer
- Space (keyboard), X (Xbox gamepad), Cross (DualShock), Y (Switch gamepad) -
  handbrake
- R (keyboard), Back/Squares (Xbox gamepad), Select/Options(?) (DualShock),
  minus (Switch gamepad) - reset
