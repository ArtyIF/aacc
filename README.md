# Arty's Arcadey Car Controller

A very work-in-progress car controller. Includes a very basic demo scene and
two cars (no way to easily switch between them).

**NOTE**: please pay attention to the `attribution.txt` files in the
`addons/aacc` folder! Some files' licenses require attribution if you're going
to use them!

## Dependencies
- Godot 4.x (tested on 4.3)
- [lawnjelly's smoothing addon](https://github.com/lawnjelly/smoothing-addon/tree/4.x)
  for physics interpolation in Godot versions below 4.4
- [Hydraboo's TrailRenderer](https://github.com/Hyrdaboo/TrailRenderer)
  for skid trails
- Blender 3.5 or later (3.0-3.4 might also work) for the demo scene

## Demo Scene controls
- W/S (keyboard), RT/LT (gamepad) - gas and brake/reverse
- A/D (keyboard), Left Stick Left/Right (gamepad) - steer
- Space (keyboard), X (Xbox gamepad), Cross (DualShock), Y (Switch gamepad) -
  handbrake
