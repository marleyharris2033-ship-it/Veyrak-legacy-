# Veyrak: Legacy

Milestone 0.1: a touch-friendly **Godot 4.5.1** character creator for the Veyrakian species, from Veyathuun.

## Open it on an iPhone

There is no need to install Godot on your phone. GitHub Actions builds the Godot project into a browser game.

1. Open this repository in Safari and go to **Settings → Pages**.
2. Under **Build and deployment → Source**, select **GitHub Actions**.
3. Open **Actions → Build character creator**. If the first deployment ran before Pages was enabled, use **Re-run all jobs**, or **Run workflow → main**.
4. Once the deployment is green, open **https://marleyharris2033-ship-it.github.io/Veyrak-legacy-/**.

The address will only work after Pages is enabled and the deployment succeeds. Portrait and landscape layouts are supported. The first engine download can take a little time on mobile data.

## Included

- Male/female bases and a name of up to 24 characters.
- Six faces, ten hairstyles, six hair colours, six skin tones, eight marking choices (including no markings), six eye colours, four builds and six outfits.
- Live appearance preview, face inspection, randomisation and restore-last-save.
- Local character saving and a downloadable JSON backup. Local saves belong to this browser/device, not your GitHub account; clearing browser data may remove them.
- Charcoal and gold interface with a pixel-art Veyathuun backdrop. No “Activate Core”.

**Art status:** these are original code-drawn prototype layers, not the approved concept image. The renderer is separate from character data so final layered sprite art can replace it. There is no playable world, animation system or character-backup import screen yet. Appearance is cosmetic; it does not assign combat stats.

## Project layout

- `project.godot` / `creator.tscn`: Godot project and entry scene.
- `scripts/creator.gd`: responsive creator controls and save/download actions.
- `scripts/profile.gd`: versioned, validated character data.
- `scripts/portrait.gd`: replaceable pixel-layer renderer.
- `export_presets.cfg`: single-threaded web export with mobile keyboard support.
- `.github/workflows/web.yml`: build, validate and publish to GitHub Pages.

The web build uses Godot's Compatibility renderer and disables threads for iOS and standard static hosting. Exported engine binaries are build artifacts, not committed source files.

## Desktop development later

Import `project.godot` into Godot 4.5.1 and press **F6** on `creator.tscn`, or **F5** to run the project. No third-party plugins are required.

```sh
godot --headless --editor --import --path .
godot --headless --path . --script tests/profile_test.gd
godot --headless --path . --script tests/creator_test.gd
mkdir -p build/web
godot --headless --path . --export-release Web build/web/index.html
```

Web export requires the matching Godot export templates. Serve the exported directory over HTTP/HTTPS rather than opening `index.html` directly from Files.

Reference: [Godot web export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html) · [GitHub Pages configuration](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site).
