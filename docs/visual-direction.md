# Approved character creator direction

User instruction: keep the supplied setup and implement it in-game. Canon: **Veyrak: Legacy**, species **Veyrakian**, homeworld **Veyathuun**. Do not revert to older names.

Reference: `assets/creator/layout-reference.jpeg` (1536 × 1024).

Landscape composition:

- Gold Veyrak title upper left.
- Five left navigation buttons: Appearance, Markings, Eyes, Outfit, Name.
- A full-height, three-quarter male warrior in the centre, standing on the gold-ring platform.
- One right panel with eight rows in order: Body type, Face, Hair style, Hair colour, Eyes, Skin tone, Markings, Outfit.
- Rows use thumbnail choices, a selected gold border, arrows, and a selection count.
- Name and random-name control below the warrior; prominent gold Confirm Character button beneath.
- Back at lower left; the existing decorative banner and closing motto retained.
- Dark midnight-blue panels, stepped gold edges, crisp pixel art, restrained blue text.
- No Activate Core button.

Portrait: stack the same content and use full-size touch pickers from row/category headings. The background and warrior scroll together, maintaining foot-to-platform alignment. Landscape retains the reference composition instead of rearranging its columns.

## Current implementation limit

One complete male sprite is finished. Body settings scale its width, and colour settings apply a shader to bounded skin/hair/eye regions. Other faces, hairstyles, marking patterns and outfits are visibly locked until compatible artwork exists. Do not simulate unavailable choices with counters or silently replace saved selections. Female art and full modular layers are subsequent work.

Main scene: `reference_creator.tscn`. The former rectangle-drawn prototype is retained for development only. New artwork profiles carry `art_revision: 1`; pre-existing saves are not replaced until the player confirms the new draft.
