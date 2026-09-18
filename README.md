# Veyrak: Legacy

Milestone 0.3: reference-led in-game character creator, built in **Godot 4.5.1**, for Veyrakians from Veyathuun.

## Open it on an iPhone

There is no need to install Godot on your phone. GitHub Actions builds the Godot project into a browser game.

1. Open this repository in Safari and go to **Settings → Pages**.
2. Under **Build and deployment → Source**, select **GitHub Actions**.
3. Open **Actions → Build character creator**. If the first deployment ran before Pages was enabled, use **Re-run all jobs**, or **Run workflow → main**.
4. Once the deployment is green, open **https://marleyharris2033-ship-it.github.io/Veyrak-legacy-/**.

The address will only work after Pages is enabled and the deployment succeeds. Portrait and landscape layouts are supported. The first engine download can take a little time on mobile data.

## Included

- Finished male warrior and a name of up to 24 characters; female artwork is pending.
- Live body-width and colour choices. Planned ranges remain six faces, ten hairstyles, six hair colours, six skin tones, eight markings, six eye colours, four builds and six outfits; unfinished art choices are locked.
- Thumbnail rows, larger touch pickers, random names and restore-last-confirmed-look.
- Local character saving and a downloadable JSON backup. Local saves belong to this browser/device, not your GitHub account; clearing browser data may remove them.
- Charcoal and gold interface with a pixel-art Veyathuun backdrop. No “Activate Core”.

**Current in-game screen:** landscape follows the approved three-column composition: left categories, central warrior, right thumbnail rows, name panel, confirm and back buttons. The title/banner/icons are sampled from the approved reference at runtime; the whole screenshot is never used as a fake interactive screen. Portrait stacks the same components with scrolling. Tap category names or row headings for full-size touch pickers.

**Art status:** the environment and transparent default male warrior are independent generated assets. Four body-width settings and six skin, hair and eye colour settings are live. Body settings currently scale the default silhouette; they are not four independently illustrated bodies. Skin/hair/eye settings use a region-limited palette shader. Only one face, hairstyle, marking pattern and outfit are finished, so other choices in those rows are visibly locked and cannot be saved as if their art existed. Female artwork, modular face/hair/marking/outfit variants and animation still need to be created. No playable world or backup import screen exists yet. Appearance is cosmetic.

**Save compatibility:** new artwork saves carry `art_revision: 1`. Earlier prototype saves are retained until the player confirms a new artwork-compatible draft; their name is carried forward. Opening the new screen never overwrites an old save. The old prototype remains in `creator.tscn` for development, but is no longer the game's entry scene.

Asset specifications and generation prompts are in [docs/creator-art.md](docs/creator-art.md).

## Project layout

- `project.godot` / `reference_creator.tscn`: Godot project and current entry scene.
- `scripts/reference_creator.gd`: reference layout, touch pickers, naming and confirmation.
- `scripts/gold_frame.gd` / `scripts/appearance_tile.gd`: live frames and thumbnail controls.
- `scripts/creator.gd`: responsive creator controls and save/download actions.
- `scripts/profile.gd`: versioned, validated character data.
- `scripts/portrait.gd`: replaceable pixel-layer renderer.
- `scripts/art_stage.gd`: responsive composition of the new default character and environment.
- `assets/creator/`: original generated PNGs, including the character's alpha channel.
- `export_presets.cfg`: single-threaded web export with mobile keyboard support.
- `.github/workflows/web.yml`: build, validate and publish to GitHub Pages.

The web build uses Godot's Compatibility renderer and disables threads for iOS and standard static hosting. Exported engine binaries are build artifacts, not committed source files.

## Desktop development later

Import `project.godot` into Godot 4.5.1 and press **F5**. No third-party plugins are required. The included DejaVu Sans Mono font is redistributed under its accompanying `assets/fonts/LICENSE.txt`.

```sh
godot --headless --editor --import --path .
godot --headless --path . --script tests/profile_test.gd
godot --headless --path . --script tests/creator_test.gd
godot --headless --path . --script tests/reference_creator_test.gd
mkdir -p build/web
godot --headless --path . --export-release Web build/web/index.html
```

Web export requires the matching Godot export templates. Serve the exported directory over HTTP/HTTPS rather than opening `index.html` directly from Files.

Reference: [Godot web export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html) · [GitHub Pages configuration](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site).
