# 💎 Diamond Hunter — a Minecraft mini-game

A tiny, self-contained voxel mini-game in the spirit of Minecraft. You spawn in a
small procedurally-generated world of grassy hills and trees. Hidden in the stone
beneath your feet are **8 diamonds** — dig them all out as fast as you can. A glowing
"diamond detector" heats up as you get closer to the nearest one.

Built with plain HTML/CSS/JavaScript and [Three.js](https://threejs.org/) for the 3D
rendering. **No build step, no install, no internet connection required** — Three.js is
vendored locally in `vendor/`.

## ▶ How to play

Just open `index.html` in any modern browser:

```bash
# from the project folder, either double-click index.html, or:
python3 -m http.server 8000
# then visit http://localhost:8000
```

> Opening the file directly (`file://`) works too. A local server is only needed if your
> browser is strict about loading the local `vendor/three.min.js`.

Click **▶ Play**, then move your mouse to look around. Press <kbd>Esc</kbd> to release the cursor.

## 🎮 Controls

| Action            | Key / Button                          |
| ----------------- | ------------------------------------- |
| Move              | <kbd>W</kbd> <kbd>A</kbd> <kbd>S</kbd> <kbd>D</kbd> (or arrows) |
| Sprint            | <kbd>Shift</kbd>                       |
| Jump              | <kbd>Space</kbd>                       |
| Look around       | Mouse                                 |
| Mine a block      | **Left-click**                        |
| Place a block     | **Right-click**                       |
| Pick a block      | <kbd>1</kbd> – <kbd>7</kbd> (or click the hotbar) |
| New random world  | <kbd>R</kbd>                           |

## 🎯 The goal

Find and mine all **8 diamonds** buried in the stone. Your HUD shows how many you've
found, a running timer, and how many blocks you've mined. Beat the clock:

- Under **45s** → ⭐⭐⭐ Legendary miner
- Under **90s** → ⭐⭐ Solid digging
- Otherwise → ⭐ You got them all!

The **diamond detector** bar at the top warms from *Ice cold* → *🔥 Burning!* based on
your distance to the nearest remaining diamond, so use it to home in.

## ✨ Features

- First-person controls with mouse-look and pointer lock
- AABB physics: gravity, jumping, and block collision
- Voxel raycasting (Amanatides & Woo) for precise mine/place targeting
- Procedurally generated hills, trees, dirt, stone, and bedrock
- Face-culled meshing so only visible block faces are drawn (fast)
- Break and place 7 block types to reshape the world
- Procedural sound effects via the Web Audio API (no audio files)
- A proximity "treasure detector" and a timed scoring challenge

## 🗂 Project layout

```
index.html          The entire game (HTML + CSS + JS)
vendor/three.min.js  Three.js r128, vendored so the game runs fully offline
```

Everything lives in `index.html`, so it's easy to read, tweak, and hack on. Change the
constants near the top of the `<script>` (world size, number of diamonds, gravity, jump
height, block palette) to remix the game.
