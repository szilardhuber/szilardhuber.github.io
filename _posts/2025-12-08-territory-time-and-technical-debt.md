---
layout: post
title: "Territory, Time, and Technical Debt"
date: 2025-12-08
author: Szilard Huber
tags: [bevy, rust, game-dev, influence-system, day-cycle, ai, territory-control]
---

**TL;DR**: Added territory control through an influence system, implemented a day/night cycle tied to round progression, fought with cross-platform rendering bugs, and started rethinking what the AI opponent should actually be doing. The game is slowly morphing from "fox collecting food" into something that might actually resemble a strategy game.

Since the last post, I've been wrestling with the question: what makes a hex-grid game feel strategic rather than just a real-time race? The answer, apparently, involves territory control, time pressure through a visual day cycle, and an AI that does more than just grab the nearest shiny object.

## The Influence System: Territory That Actually Matters

The core addition this week is the **influence mechanic**. When you stand still on a hex for about a second, you claim it—a translucent colored overlay appears showing your territory. The agent can do the same. Claimed hexes belong to you, and here's the kicker: if you claim the opponent's base hex, you win instantly.

This transforms the game from a pure collection race into territorial control. Do you rush to collect food, or do you push toward the enemy base? Do you defend your base or gamble on offense? These are the questions I *wanted* players to ask. Whether they actually will remains an open question, since right now the AI is about as strategically sophisticated as a roomba.

![Influence / and model collision bug :) Also look at those shadows, they are beautiful ](/assets/2025/screenshot3.png)


### Implementation: Idle Time and Overlay Spawning

The system tracks idle time for both player and agent. If an entity sits on the same hex for more than `IDLE_SECONDS_TO_EXPAND` (currently 1.0s), we spawn an influence overlay on that hex:

```rust
pub fn handle_idle_time_and_expansion(
    commands: &mut Commands,
    entity: Entity,
    owner: BaseOwner,
    transform: &Transform,
    current_idle_time: f32,
    last_hex_coord: Option<HexCoord>,
    delta_secs: f32,
    // ... other params
) -> (f32, Option<HexCoord>) {
    let current_coord = geometry::coords(SIZE, transform.translation);
    
    let new_idle_time = if Some(current_coord) == last_hex_coord {
        current_idle_time + delta_secs
    } else {
        0.0  // Moved, reset idle timer
    };
    
    if new_idle_time >= IDLE_SECONDS_TO_EXPAND {
        // Attempt to claim this hex
        try_expand_influence(commands, entity, owner, current_coord, /* ... */);
        (0.0, Some(current_coord))  // Reset timer after claiming
    } else {
        (new_idle_time, Some(current_coord))
    }
}
```

The influence overlay is rendered using a custom shader material (`InfluenceMaterial`) with alpha blending, so it sits transparently over the hex tile. Player influence is orange-ish, agent influence is purple-ish. Yes, I'm continuing my questionable color choices from the UI. At this point I'm committed to the aesthetic, whether it's good or not.

### Win Condition: Base Capture

Each player has a base (the little house model spawned at the start). The base position is tracked in the `BasePositions` resource. Every frame, we check:

```rust
fn check_base_capture_system(
    base_positions: Res<BasePositions>,
    influence_state: Res<InfluenceState>,
    mut winner: ResMut<GameWinner>,
    // ...
) {
    if let Some(player_base_coord) = base_positions.player_base_coord {
        if influence_state.owned_hexes.get(&player_base_coord) == Some(&BaseOwner::Agent) {
            *winner = GameWinner::Agent;
            // Transition to GameOver
        }
    }
    // Same check for agent base
}
```

If the agent claims your base hex (or vice versa), the game ends immediately. This creates actual tension: you have to defend your base while pushing forward. Or at least, that's the theory. In practice, the AI doesn't understand this yet and will happily ignore its own base while chasing food like a golden retriever.

### Technical Challenge: Persistent Influence Across Rounds

One tricky part: influence needs to persist across rounds (you keep your claimed territory) but reset when the game restarts. This required careful resource lifecycle management:

- `InfluenceState` resource persists through Playing → Menu → Playing transitions
- Influence overlay entities are despawned when exiting Playing state
- On re-entering Playing state, we restore the overlays from `InfluenceState`
- On GameOver → Menu transition, we clear `InfluenceState` completely

This uses the `restore_influence_overlays` system that reads from `InfluenceState.owned_hexes` and respawns visual overlays for each claimed hex. It's a pattern I should have used from the start instead of treating everything as transient state.

## The Day Cycle: Visual Time Pressure

Rounds last 30 seconds. To make this feel tangible, I added a **day/night cycle** where the sun moves from east to west over the course of each round.

The sun starts in the east (positive X), arcs overhead, and sets in the west (negative X) as the round progresses. The implementation ties directly to the round timer:

```rust
fn rotate_sun(
    round_manager: Res<RoundManager>,
    mut sun_query: Query<(&mut Transform, &mut DirectionalLight), With<Sun>>,
) {
    let round_progress = round_manager.round_timer.elapsed_secs() 
        / round_manager.round_timer.duration().as_secs_f32();
    
    // Sun travels 180 degrees from east to west
    let angle = round_progress * PI;
    
    let x = radius * angle.cos();
    let y = height + radius * angle.sin().max(0.0);  // Keep sun above horizon
    
    transform.translation = Vec3::new(x, y, north_offset);
    transform.look_at(Vec3::new(0.0, 0.0, 5.0), Vec3::Y);
}
```

As the sun moves, its illuminance also changes—brighter at sunrise/sunset for dramatic lighting, dimmer at noon to reduce overexposure. This creates a subtle but noticeable shift in mood as the round progresses. Early round feels bright and hopeful. Late round feels tense and shadowy. Whether this actually affects gameplay psychology is questionable, but it looks cool, so mission accomplished.

The sun path is offset north of the grid center, which creates visible shadows to the south and prevents the entire grid from being washed out at noon.

## The Agent Problem: What Should It Even Do?

Right now, the agent uses `NearestFoodStrategy`—it pathfinds to the closest food and eats it. This worked fine when the game was pure collection, but with territory control, it's painfully inadequate.

The agent should:
- Defend its base when threatened
- Push toward the player's base when it has an advantage
- Balance food collection with territorial expansion
- React to the player's strategy

None of this exists yet. The current agent is a glorified automaton that picks the closest food and runs toward it. If its base is about to be captured, it doesn't care. If the player is one hex away from victory, it's oblivious.

I've started sketching a more sophisticated strategy system:

```rust
pub trait AgentStrategy: Send + Sync {
    fn decide_next_action(
        &self,
        agent_pos: Vec3,
        player_pos: Vec3,
        food_positions: &[Vec3],
        influence_state: &InfluenceState,
        base_positions: &BasePositions,
    ) -> AgentAction;
}

pub enum AgentAction {
    CollectFood(Vec3),      // Move to food position
    ClaimTerritory(Vec3),    // Move to unclaimed hex and wait
    DefendBase(Vec3),        // Move toward own base
    AttackBase(Vec3),        // Move toward enemy base
}
```

The idea is to have a strategy that evaluates threats and opportunities, then picks an action. Something like:

1. **Immediate threats**: If my base is threatened (player influence nearby), defend
2. **Winning condition**: If I can reach the enemy base soon, push for victory
3. **Resource needs**: If I'm low on resources, prioritize food
4. **Territorial advantage**: Otherwise, expand influence strategically

This isn't implemented yet. Right now, it's aspirational architecture. The kind of thing you sketch out and tell yourself "I'll totally build this soon" while knowing it'll probably sit half-finished for weeks.

## Cross-Platform Grid Sizing (The Boring But Necessary Part)

There was a technical problem that consumed more time than I'd like to admit: hex cells were different sizes on different screens. iOS portrait had 70px hexes, iOS landscape had 30px hexes, desktop was inconsistent. The grid also had gaps at the viewport edges.

The fix involved calculating the camera distance needed to achieve a target hex size (50px) using perspective projection math:

```rust
let camera_distance = (window_height * hex_spacing) / (2.0 * tan(fov/2) * target_hex_size);
```

Then adjusting grid dimensions based on the visible world space at that distance. It's now consistent across all devices.

The actual rabbit hole here was understanding Bevy resource lifetimes—the `OptimalCameraDistance` resource needed to persist across rounds (same lifetime as the Grid), not get cleaned up with the camera entity. Small detail, but it caused the camera to reposition incorrectly in round 2. Fixed now.

Also refactored the camera re-centering logic from a boolean flag resource to a proper Bevy event (`CameraRecenterRequested`), which is more idiomatic. Events are for one-shot signals, resources are for persistent state. Use the right tool for the job, even if the wrong tool technically works.

## What's Next?

Again, according to the AI: (my plans are different as always)

Next steps:
- **Smarter agent strategy**: Actually implement threat detection and strategic decision-making
- **Balance testing**: Does the influence mechanic feel rewarding or tedious? No idea until I play more
- **Upgrade integration**: Make upgrades affect territory control (faster claiming? larger influence radius?)
- **Visual feedback**: Better indication when hexes are being claimed, when bases are threatened
- **Mobile polish**: The grid still has alignment issues on some devices (agent runs off-screen)

The hex grid finally has a purpose beyond "looking cool"—it's now the terrain you fight over. Whether that makes for engaging gameplay is the next question to answer. The only way to know is to keep building and testing.

---

*Previous post: [From Survival to Strategy](./2025-11-27-from-survival-to-strategy.md) | Next post: TBD*
