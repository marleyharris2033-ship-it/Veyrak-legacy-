# Veyathuun Council hero records

The active creator has been replaced with a six-hero selector. Dossiers are native,
scrollable Godot UI styled as dark Council personnel files. Approved roster art is
used as intact AtlasTexture photographs: no independent faces, hairstyles or bodies.
The original creator assets remain archived in the repository but are not used by
the opening screen or endpoint.

## Data and saves
`scripts/heroes.gd` owns stable IDs, lore, skill descriptions, attributes and formulas.
`scripts/hero_selector.gd` presents dossiers; `hero_portrait.gd` renders intact art.
`profile.hero_id` is persisted in each independent slot; names follow hero identity.
Existing saves without a hero ID request explicit selection. Merely browsing does
not write anything. Confirmation preserves completed-introduction checkpoints.

## Attributes
All level-one heroes have 36 base points, each attribute in 1–10. Equipment may later
add attributes; effective values clamp to 1–30. Hero physiques are cosmetic fixed
identities; statistics reflect intended combat specialisations.

| Hero | Might | Endurance | Agility | Precision | Core | Resonance |
|---|---:|---:|---:|---:|---:|---:|
| Kaerun | 9 | 9 | 4 | 4 | 6 | 4 |
| Vaelis | 5 | 4 | 9 | 8 | 6 | 4 |
| Dhoran | 7 | 8 | 3 | 6 | 8 | 4 |
| Saevra | 7 | 7 | 5 | 4 | 9 | 4 |
| Nyvara | 4 | 4 | 8 | 10 | 5 | 5 |
| Ilyra | 3 | 5 | 6 | 5 | 8 | 9 |

Health = 100 + 20 × Endurance + 15 × (level−1).
Energy = 50 + 10 × Core.
Stamina recovery/sec = 10 + 2 × Agility.
Critical chance (%) = 2 + Precision. Base critical damage is proposed at 150%.
Melee multiplier = (1 + .05 × Might) × (1 + .035 × (level−1)).
Ability multiplier = (1 + .04 × Core) × (1 + .035 × (level−1)).
Bond effect multiplier = 1 + .03 × Resonance.
Levels currently clamp to 1–30. Precision does not multiply all ranged damage;
weapon base damage remains separate. Avoid multiplying melee and ability bonuses
together for a single damage event: each attack will use its designated channel.
Resonance applies to bond effects, not every creature attack by default.

## Scope
Stat calculations, hero selection, portraits, biographies and persistence are implemented.
Skills and specialisation paths are design descriptions. Combat, loot, equippable visual
armour, animated world sprites, XP earning and skill trees are not implemented by this change.
The art is concept/selection illustration, not a gameplay animation sheet. Future weapons
and armour must use hero-specific attachment points and corresponding animation frames.

## Validation
Godot 4.5.1 import; all six hero IDs and equal attribute budgets; name/ID round trips;
confirm, introduction, skip, endpoint, independent saves and migration without silent
writes; stat formulas/equipment additions; 390×844 and 844×390 responsive layout and
finger-sized hero buttons. Physical iPhone visual QA remains a user-device check.
