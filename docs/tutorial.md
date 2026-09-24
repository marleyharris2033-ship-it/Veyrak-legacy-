# Council training terrace

The opening endpoint now offers BEGIN TRAINING. Six fixed heroes share one bounded terrace and use their own complete sprite frames; no detached face or hair layers. This is a contained movement, interaction, basic attack, signature exercise, loot and equipment tutorial, not the main RPG world.

## Art and animation

`assets/heroes/gameplay-sprites.png` is a transparent 4-column, 6-row atlas with 256px cells. Rows follow VeyrakHeroes.IDS. Columns are front idle, front step, rear idle, rear step. HeroActor selects the row from a stable hero ID and uses nearest filtering. Two-frame stepping is the current animation baseline; dedicated directional attack, hurt and equipment-animation sheets remain future work. Complete frame silhouettes preserve each hero's build, hairstyle, armour and weapon.

## Controls and lessons

Touch stick or WASD/arrows moves. Space attacks, Q uses the signature exercise, E interacts. Native containers reserve space for controls; the clipped camera follows the hero. Objective bearing guides players to offscreen goals. No creatures or later story reveal appears.

The training constructs are harmless. Signature exercises are simplified previews: Kaerun closes into impact range, Vaelis dashes, Saevra draws the construct closer, Nyvara fires at range, Dhoran adds repeated fire, and Ilyra restores health with a resonance pulse. These do not implement the complete dossier skill trees, companion AI or class resource loops. Effects currently accompany standing/stepping sprites.

Reward: one training core, first claimed then explicitly equipped. Its +2 attribute uses the existing derived-stat formulas. No random loot, XP levelling or armour appearance changes yet.

## Persistence

Existing three-slot JSON format is retained. Scene `res://tutorial.tscn`, phase `tutorial`, lesson 0–6, claimed/equipped flags, position and play time are stored on milestones, every ten seconds, focus loss and exit. A resumed combat lesson restarts its practice construct and refills energy/health. The tutorial never overwrites another slot. Save failures remain visible and block exit.

## Verification

Headless Godot test covers each hero, animation row, portrait 390×844 and landscape 844×390 controls, movement, proximity gates, combat, ability lesson deadlock prevention, loot/equip, completion and resume. Existing opening/profile/save-slot tests also remain in CI. Actual iPhone Safari and visual animation QA still need device testing.
