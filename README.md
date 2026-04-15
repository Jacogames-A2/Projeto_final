# Turma A2 — Battle Arena

A local 2-player battle arena game built with **Godot 4.6**.

---

## Gameplay

Two players fight in a contained arena. The first player to win **3 rounds** wins the match.

A round ends when one player's health reaches zero. Both players then respawn and the next round begins automatically.

---

## Controls

| Action       | Player 1 | Player 2     |
|--------------|----------|--------------|
| Move Left    | `A`      | `Left Arrow` |
| Move Right   | `D`      | `Right Arrow`|
| Jump         | `W`      | `Up Arrow`   |
| Attack       | `F`      | `L`          |

---

## Project Structure

```
turma-a-2/
├── Artes/
│   ├── Arenas/        # Arena background and tile sprites
│   ├── Personagens/   # Character spritesheets
│   ├── Poderes/       # Power-up icons and effects
│   ├── Item/          # Item sprites
│   └── Obstaculos/    # Obstacle sprites
│
├── Cenas/
│   ├── cena_inicial.tscn        # Title/menu scene (placeholder)
│   ├── Arenas/
│   │   └── arena_base.tscn      # Main battle arena scene
│   └── Personagens/
│       └── base_personagem.tscn # Base character prefab
│
└── Scripts/
    ├── Auxiliar/
    │   └── game_manager.gd      # Global game state (autoload)
    ├── Arenas/
    │   └── arena.gd             # Arena logic (spawning, scoring, win)
    └── Personagens/
        └── base_personagem.gd   # Character movement, health, attack
```

---

## Architecture

### GameManager (Autoload singleton)
Tracks scores across rounds. Emits `game_over(winner)` when a player reaches `max_score`. Reset with `reset_scores()`.

### base_personagem.gd
- Set `player_index` (1 or 2) to assign controls automatically.
- Exposes `take_damage(amount, knockback_dir)` and `respawn(position)`.
- Emits `health_changed(hp, max_hp)` and `player_died(player_index)`.
- Add the node to the `"players"` group so attack hit detection works.

### arena.gd
- Spawns two instances of the character scene.
- Listens to `player_died` → awards a point → resets the round.
- Updates health bars and score label via UI nodes.

---

## Adding a New Character

1. Duplicate `Cenas/Personagens/base_personagem.tscn`.
2. Replace the `AnimatedSprite2D` frames with your spritesheet.
3. Override stats (`max_health`, `SPEED`, etc.) via `@export` in a subclass script that `extends base_personagem`.
4. Assign the new scene to the `player_scene` export on the Arena node.

## Adding a New Arena

1. Duplicate `Cenas/Arenas/arena_base.tscn`.
2. Reposition or reshape the `StaticBody2D` collision nodes.
3. Add art nodes (Sprite2D, TileMapLayer) for the background and platforms.
4. Set the new scene as the main scene or wire it up from a menu.

---

## Setup

1. Open the project folder in **Godot 4.6**.
2. The editor will import assets automatically.
3. Press **F5** (or the Play button) to run — the arena scene launches directly.
