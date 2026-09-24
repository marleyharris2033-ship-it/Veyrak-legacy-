# Field kit and mobile combat

The field menu has Pack, Gear and Stats tabs, with a scrollable body in portrait and landscape. Pack assigns rations/nectar to three quick slots; taps consume one item and restore health/core only when needed. Counts, assignments, equipment and permanent upgrades live in checkpoint.state.kit. Existing saves migrate without losing progress. Three tutorial upgrade points are awarded once, including to previously completed saves.

Gear supports the obtainable training core: equip/unequip changes the real attribute bonuses. The current terrace does not yet drop a range of weapons or armour. Starter supplies are three health rations and two core nectars. Stats spend earned points; the wider XP/level progression and creature/Resonance combat remain future work.

Touch actions listen to independent finger indices and suppress duplicate emulated-mouse activation. Movement retains its captured finger while another finger strikes. Hits use facing/movement direction with a forward cone, including up/down and diagonals; attacks no longer automatically swivel towards the practice target. Sprite artwork still has limited directional poses, even though hit detection/effects support all directions.

Dodge uses 15 core energy, moves for 0.22 seconds, and has a 1.2-second cooldown. It clamps to terrace bounds and exposes can_receive_damage() for future enemy attacks. The current training constructs remain harmless. Keyboard: I/Escape menu, 1–3 food slots, Shift dodge, Space strike, Q core ability.

Tests: existing opening and saves, all six tutorials, migrated rewards, upgrade effects, food counts, menu sizing, simultaneous two-finger stick/strike dispatch, four-direction moving hits, rear-target rejection, dodge displacement/window and persistence. Real iPhone touch/visual review remains necessary.
