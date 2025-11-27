---
title: "From Survival to Strategy: Adding AI Competition and Round-Based Gameplay"
date: 2025-11-27
author: Szilard Huber
tags: [bevy, rust, game-dev, ai, competitive-gameplay, rounds-system, upgrades]
---

**TL;DR**: The simple fox-and-food survival game evolved into a competitive strategy game with an AI opponent, round-based progression, upgrade systems, and dynamic difficulty. What started as a solo survival challenge is now a tense race for resources. Is this how the final game mechanic will look like? Absolutely not.

Eight days ago, we had a playable but simple game: one fox collecting food on a procedurally generated hex map. Today we have a competitive strategy game where you race against a dark fox AI opponent across multiple rounds, make tactical upgrade choices between rounds, and face increasingly difficult resource management challenges. This post chronicles the transformation from a basic survival mechanic into a complete competitive game loop with strategic depth.

## The Vision: From Solo to Competitive

The original game loop worked: move around, collect food, avoid starvation. But it lacked tension beyond your own mistakes. The question became: what if you weren't alone? What if another creature competed for the same scarce resources? 

This led to the creation of the **Agent system**, a pluggable AI architecture that spawns a competing fox with its own hunger timer, pathfinding, and collection mechanics. Specifically the `AgentStrategy` trait that allows different AI behaviors to be swapped in easily. Currently, there's just `NearestFoodStrategy` (beeline for closest food like a desperate college student at a buffet), but the architecture *theoretically* supports future strategies like "avoid the player," "claim territory," or "optimize for resource efficiency." Whether I'll actually implement those or just leave this as aspirational documentation is anyone's guess.

The agent spawns away from the player (4-6 tiles away) in a valid grass or sand tile and immediately starts competing. To distinguish it visually, the agent fox receives a dark material override applied recursively to its entire mesh hierarchy, giving it a nearly black appearance. Yes, I made the villain fox dark and menacing. I'm aware this is the visual storytelling equivalent of putting a mustache on a bad guy, but honestly, I just wanted to see the difference for myself and didn't want to spend any more time on it for now. Later on I'll like to find (buy?) some more models but it's good to know that existing models can be "repainted" relatively easily from code.

## Shared Movement: Refactoring with Traits

As soon as we had two entities needing movement (player and agent), code duplication became a problem. Both needed pathfinding, goal management, animation control, and terrain-aware speed adjustment. The solution: the **Movable trait**.

```rust
/// Trait to provide access to `goal` and `path` for movable entities.
pub trait Movable {
    fn goal_mut(&mut self) -> &mut Vec3;
    fn path_mut(&mut self) -> &mut VecDeque<Vec3>;
}
```

By implementing this trait for both `Player` and `Agent`, we extracted a shared `step_movement` function that handles all movement logic in one place. This function accepts any `Movable`, updates position, handles rotation, respects terrain costs, and pops waypoints from the path queue. The result: zero code duplication and consistent behavior across entities. Animation state management was similarly unified with `set_animation_state<D>`, which pauses or resumes animation based on movement.

## The Rounds System: Resource Economy and Win Conditions

With two competitors, we needed stakes. Enter the **Rounds system** which transforms the game from endless survival into a timed competition with clear victory conditions.

### How Rounds Work

Each round lasts 30 seconds. Both actors start with 5 resource units. Every 10 seconds, both consume 1 resource automatically-hunger is relentless. Food collection adds resources (with potential bonuses from upgrades). If either actor hits zero resources, the round ends immediately, and the starved actor loses.

After 5 rounds, the game ends and compares total remaining resources to determine the final winner. This could creates a fascinating strategic tension in the future: do you aggressively collect food early, or focus on upgrades that compound value over multiple rounds? To be honest here, I haven't yet added too many upgrade choices and the AI player is too dumb so currently the game isn't much of a challenge to anyone who has ever seen a computer before. I guess my target audience (haven't seen computer but has Steam or App Store available) is very limited at the moment.

The implementation uses three systems:

1. **`round_timer_system`**: Ticks the round timer and handles transitions to Menu (for upgrades) or GameOver (after final round)
2. **`consumption_tick_system`**: Automatically drains resources every 10 seconds from both actors
3. **`check_starvation_system`**: Monitors resource counts and immediately ends rounds if anyone starves

One detail: the `round_end_requested` flag allows external systems (like starvation detection) to request immediate round termination, decoupling round logic from specific failure conditions.

## Technical Deep-Dive: The Upgrade System Architecture

Between rounds, players visit the upgrade shop to spend resources on permanent improvements. The architecture here needed separation of concerns and extensibility.

### Upgrade Types and Attributes

Three upgrade types exist at the moment:
- **ReduceConsumption**: Increases hunger timer by 5 seconds (survive longer between collections)
- **IncreaseSpeed**: 1.2x movement speed multiplier (reach food faster)
- **BetterYield**: +1 bonus resource per food collected (efficiency compounding)

These upgrades modify `ActorAttributes` (a resource struct with `hunger_seconds`, `speed_multiplier`, and `yield_bonus`). Separate `PlayerAttributes` and `AgentAttributes` resources wrap `ActorAttributes`, allowing independent progression for both competitors.

The critical insight: upgrades don't modify systems—they modify resources that systems query. When the player eats food, the `player_eat_food` system checks `PlayerAttributes` and applies `yield_bonus`:

```rust
// From src/player.rs:186 (approximate)
let mut yield_amount = 1u32;
if let Some(attrs) = player_attrs {
    yield_amount = yield_amount.saturating_add(attrs.0.yield_bonus);
}
remaining.player = remaining.player.saturating_add(yield_amount);
```

Similarly, the agent's movement system queries `AgentAttributes` to multiply speed, and hunger timers respect `hunger_seconds` values during reset. This data-driven approach means I can add new upgrades without touching any of the core systems.

### The Upgrade UI

The menu system detects whether it's the first round (shows title screen) or a later round (shows upgrade shop). The shop displays cards for each available upgrade with cost, name, and description. Cards are styled with neon cyan/magenta borders using the unified `ui_theme` module. Yes, neon cyberpunk colors for a game about a fox eating food cubes. I have no defense for this aesthetic choice. I just felt the AI generated UI ugly and "make it more cyberpunk like" was my only idea on how to have a chance to make it look better. (Absolute honesty, the look and feel is still terrible, but the terrible thing is the more I see it the more I like it. Let's hope I don't get too used to it so I will spend some time on aestethics in the near future.)

When an upgrade is purchased, `handle_upgrade_selection` applies it to `PlayerAttributes`, deducts cost from `RemainingResources.player`, and the AI agent receives a balancing upgrade to keep competition fair. This prevents runaway player dominance and maintains tension across rounds. This is still very far from what I want to do, my vague idea on this is to reward the winner of the round but still offer some boost to the round loser. (Now that I'm writing it, how about offering three choices of upgrades to the winner and after he selects, offer the choice between the remaining two to the opponent but on a discount. My main concept on game design choices here is the question: "what if it were a board game").

## Dynamic Grid Sizing and Cross-Platform Support

A less glamorous but essential improvement: **viewport-aware grid sizing**. Previously, the grid was a fixed size, which caused layout issues on different screen aspect ratios (especially mobile). Or as I like to call it, "the reason half the game was off-screen on my iPhone."

The solution: query viewport dimensions in `setup_grid` and calculate grid size dynamically:

```rust
// Pseudocode from grid.rs:
let viewport_width = camera.viewport_width;
let viewport_height = camera.viewport_height;
let q_size = calculate_from_width(viewport_width);
let r_size = calculate_from_height(viewport_height);
```

This ensures the grid always fits the screen, whether you're on a 16:9 desktop monitor, a 4:3 iPad, or a 19.5:9 phone. Combined with the HUD's absolute positioning, the game now feels native on every platform. "Feels native" is developer-speak for "I finally got it to not look completely broken on at least three devices I tested.". To be honest here, I have some debts on this front as well as the grid *MOSTLY* fits the screen right now but is still misaligned so the AI player still runs off the screen like a lunatic time and time again which kind of ruins the atmosphere... 

## Testing and Quality

With increased complexity came the need for tests. The codebase now includes unit tests for critical systems:

- **Movement tests**: Verify path queue behavior, idle detection, and movement state transitions
- **Rounds tests**: Test starvation detection, round transitions, and winner determination
- **Animation ownership tests**: Ensure correct entity hierarchy traversal

These tests use Bevy's `World` and `SystemState` APIs to create minimal ECS environments, insert components, run systems, and assert correct behavior. They provide confidence that refactoring won't break core mechanics. Or at least, they provide the *illusion* of confidence, which is honestly close enough at this point.

## The Game Over Experience

The Game Over UI now displays context-aware messages:
- **"YOU WIN!"** (green) if you outlasted the agent
- **"YOU LOST!"** (red) if you starved first  
- **"GAME OVER"** (neutral) for ties or max rounds reached

The UI uses a semi-transparent overlay with a styled panel, matching the neon cyberpunk aesthetic established in `ui_theme.rs`. Again, I'm doubling down on these questionable color choices. The "New Game" button instantly restarts, resetting all state and generating a fresh map.

State management was particularly tricky here. The game needs to:
1. Persist the camera through `Playing → GameOver` (so UI renders correctly)
2. Despawn all game entities on exit (food, agents, scene lights)
3. Reset all resources (`RemainingResources`, `RoundManager`, spawn flags)
4. Re-center camera when restarting

This was achieved through careful use of marker components (`PlayingHud`, `GameOverOverlay`, `AgentSceneMarker`) and `OnEnter`/`OnExit` systems that despawn marked entities and reset resources.

## What's next?

There is a very valid question right now. Why the hell do we have hexagonal grid if the whole game is real-time? I hope
I can solve this mistery before the next post but to be honest I just really-really hope that my vague idea around here
will actually work as game mechanic.

As just for my own fun I'm leaving here the next steps the AI blogging agent thought we will be taking from here:

- **Multiple agent strategies**: Add "defensive" (avoid player), "greedy" (hoard resources), or "adaptive" (learn from player behavior) strategies. The trait system is ready for this!
- **Upgrade balancing**: Tune costs and effects based on playtesting data.
- **Audio feedback**: Sound effects for food collection, round transitions, and victory/defeat. The game is currently eerily silent, like a nature documentary without narration.
- **Visual polish**: Particle effects for food spawning/collection, trail effects during movement. Because nothing says "professional game" like excessive particle effects.
- **Leaderboard system**: Persistent high scores with round survival records
- **Map variety**: Different biome types (desert, tundra, volcanic) with unique mechanics
- **Power-ups**: Temporary effects like speed bursts or vision expansion
- **Difficulty settings**: Adjust agent intelligence, resource scarcity, round count
- **Mobile input improvements**: Better touch handling for precise hex selection
- **Performance profiling**: Optimize for 60fps on web/mobile platforms.
- **Save system**: Persist player upgrades and progress across sessions

---

*Previous post: [Building a Complete Game Loop](./2025-11-19-building-a-complete-game-loop.md) | Next post: Coming soon (probably)...*
