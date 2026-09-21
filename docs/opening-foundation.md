# Opening foundation checkpoint

New flow: title, three saves, character creation, monologue, Begin Your Legacy.
Save slots use independent versioned JSON files in Godot user://, atomically renamed
from temporary files. Browser persistence depends on IndexedDB/site storage.
Confirmed characters save their monologue position and play time; Skip writes the
endpoint checkpoint. Reset requires confirmation and does not affect other slots.

Appearance uses separate generated body/outfit, face and hair atlases, a palette
shader, and biological marking/ridge overlays. Profile indices are validated and
serialisable for eventual gameplay sprites and NPC generation. Original artwork
is retained. Atlas artwork was generated using the built-in image tool from the
approved male reference: heroic charcoal/ivory/gold Veyrakian outfit variants,
eight face structures for each base, and independent hairstyle overlays.

Main modified files: scripts/home.gd, profile.gd, save_slots.gd,
reference_creator.gd, project.godot, .github/workflows/web.yml.
New files: scripts/appearance.gd, assets/creator/modular/*,
tests/opening_test.gd, this document.

Validation: Godot 4.5.1 headless import and opening flow test passed. Tests cover
all option indices, confirm/name persistence, full monologue, skip, returning to
title, resuming endpoint, independent slots and deletion. Profile validation and
slot integrity tests are also run by CI.

This is a requested early test checkpoint, not a completed visual sign-off.
Remaining: browser/iPhone visual QA, exact layer alignment across all combinations,
rendered distinction checks, touch/keyboard testing and browser reload persistence.
No audio assets were present; Master/Music/SFX buses and preferences are functional.
The backdrop is the approved city view, not a newly generated planet view.
The main RPG world is intentionally not included.
