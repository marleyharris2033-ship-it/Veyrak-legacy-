# Character creator artwork — first integration

This documents the initial asset milestone. The current in-game screen and locked-variant behaviour are described in [visual-direction.md](visual-direction.md); the separate artwork-preview tab described below belongs to the earlier development scene.

Created with the built-in image-generation tool from the user's approved character-creator reference. Original outputs are copied unchanged; no background-removal heuristics or palette processing has been applied.

| Asset | File | Size | Role |
| --- | --- | --- | --- |
| Veyathuun | `assets/creator/veyathuun-background-v1.png` | 1536 × 1024 | Clean landscape; no character, UI or text |
| Default male Veyrakian | `assets/creator/veyrakian-default-v1.png` | 1024 × 1536 | Separate full-body RGBA sprite with transparent surroundings |

The art stage centres the platform near source coordinate (736, 810). The character's foot contact is near (525, 1465). Rendering uses nearest-neighbour filtering and responsive cover/contain calculations. The PNG alpha is preserved exactly as generated.

## Scope

This milestone establishes the look of one default character in the environment. The complete sprite has hair, markings and clothing baked into it. It must not be presented as rendering arbitrary saved selections. Artwork preview is therefore clearly separate from the original working customisation view. Saved data is unchanged.

Next asset work: aligned male/female bases, face/hair/marking/outfit layers, thumbnail renders and interface ornamentation. Use consistent pose, canvas, pixel density, anatomical anchors and lighting across each compatible base. The current full-body PNG is a visual reference, not a substitute for that modular work.

## Generation prompts

### Environment

Use case: precise-object-edit. Asset: standalone landscape background for an actual Godot character creator, 1536x1024. Reference image is the approved visual target. Recreate its magnificent Veyathuun pixel-art environment faithfully, but REMOVE ALL UI, all text/logos/lettering, every menu, every thumbnail and the central warrior. Reconstruct the environment behind all removed elements. Retain the blue starry sky, enormous blue planet, pale smaller moon, monumental blue-black and gold futuristic fantasy towers, flying craft, waterfalls, vines, gold sigil banners, torchlit columns and reflective dark tiled foreground. Retain an EMPTY circular gold-edged character platform around the lower centre at 48% width and 78% height, so a separate character sprite can stand there. Wide scene with detailed architecture filling the formerly covered left and right. Match the crisp, intricate pixel-art clusters, moody cobalt/charcoal and warm golden illumination of the reference, not smooth painterly art. No people, no character, no words, no buttons, no interface, no watermarks. Deliver only the clean environment asset.

### Character

Use case: background-extraction / identity-preserve. Asset: ONE standalone transparent PNG character sprite for Godot Veyrak: Legacy character creator. Reference is the approved screen; extract/recreate ONLY its central full-body male Veyrakian warrior, preserving his exact design and intricate crisp pixel-art style. Real alpha-transparent background; no checkerboard baked in, no scenery, no platform, no floor, no UI, no lettering, no extras. Full body from hair tips to boot soles with generous clear padding on every edge, portrait 1024x1536. Match reference: muscular athletic adult alien man, pale warm grey skin, angular serious face, subtle cranial/brow ridges, dark blue-grey geometric temple/shoulder/arm markings, spiky swept-back black hair; three-quarter facing screen-right, feet apart, fists relaxed at sides. Black wrapped scarf and asymmetrical sleeveless cropped black top exposing muscular abdomen, charcoal loose trousers and split draped cloth, intricate antique-gold edging, gold waist medallion, central black/gold tabard with slim abstract species sigil, black/gold wrist gauntlets and shin armour and boots. Keep the reference anatomy and outfit rather than inventing sci-fi plate armour. Warm gold highlights from front-left and subtle cool blue rim light. Clean silhouette, no weapon, no glow cloud, no ground shadow. High quality pixel sprite with deliberate small square pixel clusters and sharp limited-palette shading, not smooth illustration. One character only, not a sprite sheet. Character centred, occupies about 86 percent of canvas height.
