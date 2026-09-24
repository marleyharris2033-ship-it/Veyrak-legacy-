# HUD and combat polish

The terrace now fills the viewport. A charcoal/gold portrait panel, health/core bars and live objective minimap replace permanent lesson text and compass readouts. A white dot is the player, a gold diamond the destination, and blue the Council projection. Touch controls overlay the lower corners; Talk/Collect/Equip appears near the relevant object. The menu saves and returns to title.

NPC dialogue opens only through interaction, stops movement/combat, and advances its lesson on Continue. Equipment notifications expire; save errors remain visible. Existing saves retain their lesson and equipment state.

Kaerun's source sheet is irregular, not an 8×6 grid. Individually authored pose rectangles and feet pivots now select actual punches and ground-slam poses. Other heroes retain their existing artwork and gain recoil/lunge movement, moving projectiles or slash arcs, and impact particles. They do not yet have bespoke attack sprite sheets.

Headless tests cover all six lesson flows, dialogue gating, portrait/landscape controls, full viewport arena, minimap containment, actual punch-frame selection, and save/resume. Device visual review remains necessary, especially the boundaries of the original irregular generated artwork; these are authored atlas crops, not newly redrawn animation frames.
