---
title: "Fragments of Instinct: When Bases Learn to Build Armies"
date: 2026-01-19
author: Szilard Huber
tags: [bevy, rust, game-dev, architecture, ecs, spawning, emergent-behavior, game-design]
---

## The World That Wanted to Run Itself

In the last post, we had single agents with utility-based AI—foxes that pathfound around the map, making strategic decisions about food, territory, and defense. Each team had one agent. You controlled one fox, the AI controlled another, and they competed for dominance.

Then we were kind of ready for the original idea of the game: what if bases spawned units automatically and the player
only "lead" them?

Instead of one permanent agent per team, bases would generate units on a timer. Every 10 seconds, if you're below the unit cap, a new fighter appears at your base and joins the fray. Lose a unit in combat? Your base replaces it eventually. Win a battle? You have numerical superiority until the opponent catches up.

The implementation was straightforward—add an `AgentSpawner` component to bases with a repeating timer:

```rust
#[derive(Component, Debug)]
pub struct AgentSpawner {
    pub timer: Timer,
    pub spawn_count: u32,
}
```

Every frame, the `auto_spawn_agents` system ticks the timers. When one finishes, it checks the team's unit count. Under the cap? Spawn a new unit at the base's coordinates. Reset the timer. Repeat forever.

A resource economy driven by time rather than manual intervention. Bases constantly generate units unless capped.

## Two Kinds of Presence

The original agents represented something conceptual: the *idea* of a team's presence on the map. They sat at the base, marking territory, serving as the anchor point for spawning. They didn't need to move or fight because they weren't combatants. They were more like... flags. Symbols. Markers of influence.

The spawned units were the opposite: fragments of that presence given form. Temporary, expendable, active. They pathfind, fight, gather resources, expand territory. When they die, they're gone—but the base can create more.

This distinction needed to be reflected in the code. So I split the architecture:

**Aspects**: Stationary entities at each base. Semi-transparent foxes that represent the team's presence without directly participating. They have a `TeamId`, occupy the base hex, and serve as the visual anchor. No movement, no combat, no hunger. They just... exist.

**Shards**: Active combat units spawned from bases. Brown/orange cubes for Team 1, red cubes for Team 2. They have all the gameplay components—health, hunger, utility-based AI, pathfinding, combat stats. When a Shard's health reaches zero, it despawns. The base eventually spawns a replacement.

The code became clearer because the names finally matched the design. Queries separated cleanly:

```rust
// Only active units
fn process_combat(shards: Query<&Health, With<Shard>>) { ... }

// Only stationary markers
fn render_aspect_ghosts(aspects: Query<&Transform, With<Aspect>>) { ... }
```

## Death Without Revival

With the spawning system in place, respawning became obsolete. When a Shard dies in combat, it despawns. That's it. No respawn timer, no comeback mechanic. The entity is gone until the base spawns a new one.

This sounds harsh, but it makes battles matter. Losing a Shard isn't a temporary setback—it's a real loss that takes 10 seconds to recover from. Winning a fight gives you a window of numerical superiority. Combat becomes about creating and exploiting those windows rather than slowly grinding the opponent down.

From a technical perspective, this simplified everything. Death triggers a `DeathEvent`, the entity despawns, cleanup runs. No need to track respawn timers per entity, no edge cases around "what if death happens while respawn is queued." Clean, deterministic, easy to reason about.

## Team Architecture and Collision

Underneath these changes, the codebase continued migrating from binary "Player vs Agent" to a flexible team system. Every entity that belongs to a team now has a `TeamId` component. Hunger timers, influence tracking, combat stats—everything keys off `TeamId` rather than hardcoded ownership flags. This means adding a third or fourth team is now configuration, not a rewrite.

The spawning system also required collision handling. Multiple Shards spawning at the same base hex, then spreading out across the map. The `OccupiedHexes` resource prevents stacking (except on base hexes, which explicitly allow multiple units for spawning).

When a Shard tries to move, the movement system checks if the target hex is occupied. If it is, the Shard's `blocked_time` counter increments. After 2 seconds of being blocked, it recalculates its path. This creates emergent traffic flow—units naturally spread out because cramming together is inefficient.

To be honest this logic and/or system is still flawed, for simplicity, performance reasons and maybe fun factor I'm
thinking of adding a system where units from the same team would merge if they move to the same cell, making them more
powerful, more resiliant while also adding some more gameplay value to the team limit that we introduced.

## Where We Stand

The architecture is starting to cohere. Aspects sit at bases, radiating presence. Shards spawn automatically on a timer. They pathfind across the hex grid, collect food, engage in combat, expand territory. Death is permanent but replaceable. Teams are flexible and data-driven.

What's missing is depth. The AI uses utility-based decision-making, but strategies are identical across teams. Bases spawn Shards, but there's no distinction between defensive and aggressive playstyles. Combat works, but there's no rock-paper-scissors asymmetry to make composition interesting.

That's fine. The foundation can support those features now without collapsing. This round of work was about getting the architecture solid—ensuring the codebase can grow without becoming brittle.

The rename from `PrimaryAgent/SecondaryAgent` to `Aspect/Shard` came last. Once the two-tier system was working and the roles were clear, the old names felt wrong. They described implementation hierarchy ("primary" and "secondary") rather than conceptual purpose. Renaming forced clarity: what *are* these entities, really?

Aspects spawn Shards. Shards compete for territory. Death removes pieces from the board. It's simple, but it runs itself.

---

*Previous post: [From Roomba to Strategist](./2026-01-06-from-roomba-to-strategist) | Next post: TBD*
