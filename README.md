# Arty's Arcadey Car Controller

A very work-in-progress car controller that kinda resembles Midnight Club
physics? I guess? Includes a very basic demo scene and only one proper car.

## Dependencies
- Godot 4.x (tested on 4.3)
- [lawnjelly's smoothing addon](https://github.com/lawnjelly/smoothing-addon/tree/4.x)
  for physics interpolation in Godot versions below 4.4
- [Hydraboo's TrailRenderer](https://github.com/Hyrdaboo/TrailRenderer)
  (preferably in this repository currently, as the original one has a bug until
  its PR #3 is merged) for skid trails
- Blender 3.5 or later (3.0-3.4 might also work) for the demo scene

## Demo Scene controls
- W/S (keyboard), RT/LT (gamepad) - gas and brake/reverse
- A/D (keyboard), Left Stick Left/Right (gamepad) - steer
- Space (keyboard), X (Xbox gamepad), Cross (DualShock), Y (Switch gamepad) -
  handbrake

## Tricks

- Hold the handbrake (Space) and steer at a high enough speed to perform a 180
  turn!

https://github.com/user-attachments/assets/0ea0236d-79a3-41c5-b0a3-a695d730ea14
- That's it for now
