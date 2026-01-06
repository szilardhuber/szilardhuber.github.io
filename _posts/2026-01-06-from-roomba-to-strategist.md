---
title: "From Roomba to Strategist: Teaching AI to Actually Play the Game"
date: 2026-01-06
author: Szilard Huber
tags: [bevy, rust, game-dev, ai, utility-based-ai, headless-simulation, code-architecture]
---

**TL;DR**: Replaced the brain-dead "chase nearest food" AI with a utility-based decision system that evaluates five different roles (capture, defend, gather, expand, idle). Added headless simulation mode for fast AI vs AI testing with time acceleration up to 1000x. Refactored the codebase to separate rendering from headless modes. The AI can now actually make strategic decisions instead of acting like a Roomba with a goal.

In the last post, I described the AI agent as "about as strategically sophisticated as a roomba." That wasn't hyperbole. The `NearestFoodStrategy` would identify the closest food cube, pathfind toward it, and collect it. If its base was being captured, it had no idea. If the player was one hex away from victory, it remained oblivious. It was less "opponent" and more "animated lawn ornament."

The fundamental problem: the game had evolved into a territorial strategy game, but the AI was still playing the original "collect food" prototype. Time to fix that.

## The Utility-Based AI: Making Decisions Like a Human (Sort Of)

The core insight behind utility-based AI is simple: evaluate every possible action by how useful it would be right now, then pick the best one. Instead of hardcoded rules ("if X then Y"), the AI continuously asks "what would help me most at this moment?"

I defined five roles the agent could adopt:

```rust
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AgentRole {
    Capture,          // Take enemy territory
    Defend,           // Protect own base
    GatherFood,       // Avoid starvation
    ExpandInfluence,  // Claim neutral hexes
    Idle,             // Fallback when nothing else makes sense
}
```

Each role has an evaluation function that returns a utility score from 0.0 to 1.0 (or higher for critical situations). The agent picks whichever role scores highest. For example, the `GatherFood` utility calculation:

```rust
fn evaluate_gather_food_utility(
    &self,
    agent_pos: Vec3,
    food_positions: &[(Entity, Vec3)],
    remaining_resources: u32,
) -> f32 {
    if food_positions.is_empty() {
        return 0.0;
    }
    
    let nearest_food = /* find closest food */;
    let distance = agent_pos.distance(food_pos);
    
    // Closer food = higher utility
    let distance_factor = (1.0 - (distance / scale).min(1.0)).max(0.0);
    
    // Starving? Boost gathering priority dramatically
    let hunger_factor = if remaining_resources <= starvation_threshold {
        1.0 + starvation_boost * (1.0 - resources / threshold)
    } else if remaining_resources >= comfort_threshold {
        0.5  // Reduce priority when comfortable
    } else {
        1.0
    };
    
    base_weight * distance_factor * hunger_factor
}
```

When the agent has 3 resources left and food is nearby, `hunger_factor` might be 1.5, dramatically boosting the gathering utility. When it has 10 resources, `hunger_factor` drops to 0.5, making other roles more attractive. The AI naturally shifts priorities based on context.

The defend role does something similar but checks for threats:

```rust
fn evaluate_defend_utility(
    &self,
    influence_state: &InfluenceState,
    agent_base_coord: &HexCoord,
    player_position: Option<Vec3>,
) -> f32 {
    // Check player distance from base
    let player_threat_distance = /* calculate hex distance */;
    
    // Check nearest enemy influence
    let mut nearest_enemy_influence = isize::MAX;
    for (hex_coord, owner) in &influence.owned_hexes {
        if *owner == BaseOwner::Player {
            let distance = hex_distance(base_coord, hex_coord);
            if distance < nearest_enemy_influence {
                nearest_enemy_influence = distance;
            }
        }
    }
    
    // CRITICAL: If both player AND influence are very close, skyrocket utility
    if player_threat_distance <= 2 && nearest_enemy_influence <= 2 {
        return 3.0;  // Exceeds normal 0-1 range to force immediate defense
    }
    
    /* otherwise calculate threat urgency normally */
}
```

When the base is under siege—player approaching AND enemy influence nearby—the defend utility jumps to 3.0, overriding everything else. The AI abandons food collection and rushes home. This creates emergent behavior: early game, the AI expands aggressively. Mid-game, it balances food and territory. Late game, if you push toward its base, it panics and defends.

## Role Inertia: Preventing Indecisive Flip-Flopping

One problem with utility systems: if two roles have similar scores, the AI can oscillate between them every frame. The agent would take one step toward food, recalculate, decide capturing territory is slightly better, turn around, recalculate again, and end up spinning in circles like a confused dog.

The solution: **role inertia**. The AI won't switch roles unless the new role's utility is at least 80% better:

```rust
// Only switch if current utility < 80% of best utility
let should_switch = current_utility < 0.8 * best_utility;
```

Additionally, after switching roles, the agent is locked into that role for 1 second minimum. This creates commitment: once the AI decides to defend, it actually follows through instead of getting distracted halfway.

The result: smooth, purposeful behavior. The AI moves with intention rather than jittering between half-completed plans.

## The AgentVsAgent Bug: When Hardcoded Assumptions Break

With the new AI working, I wanted to test it properly: two AIs competing with no human player. This revealed a critical bug I'd introduced weeks earlier.

The problem was in the agent eating logic. When checking whether the agent owned territory, I had hardcoded:

```rust
// WRONG: assumes agent is always BaseOwner::Agent
if influence.owned_hexes.get(&coord) == Some(&BaseOwner::Agent) {
    // Agent is on its own territory
}
```

This works fine in PlayerVsAgent mode. But in AgentVsAgent mode, one AI controls the "Player" side (using `BaseOwner::Player` ownership) while the other controls "Agent" side. The agent-as-player couldn't recognize its own territory because it was looking for the wrong ownership marker.

The fix required tracking which side each strategy was controlling:

```rust
pub struct UtilityBasedStrategy {
    // ... other fields ...
    owner: BaseOwner,  // Which base this strategy controls
}

// Returns enemy owner based on our owner
fn enemy_owner(&self) -> BaseOwner {
    match self.owner {
        BaseOwner::Agent => BaseOwner::Player,
        BaseOwner::Player => BaseOwner::Agent,
    }
}
```

Now each AI knows which territory is "ours" and which is "theirs," regardless of whether it's controlling Player or Agent. The bug was subtle but completely broke AgentVsAgent mode—one side thought it owned nothing and couldn't make territorial decisions.

## Refactoring: One Codebase, Two Execution Modes

The next challenge: how do you test AI vs AI at high speed without waiting 30 seconds per game? Enter headless mode.

The idea: run the game with no rendering, no window, no graphics pipeline—just the ECS simulation. Use Bevy's `Time<Virtual>` to accelerate time by 10x, 100x, or even 1000x. A 30-second game becomes 0.03 seconds of real time.

This required splitting `main.rs` into two separate entry points:

```rust
// main.rs
#[cfg(feature = "rendering")]
fn main() {
    bevy_game::rendering_main::run();
}

#[cfg(feature = "headless")]
fn main() {
    bevy_game::headless_main::run();
}
```

**Rendering mode** (`cargo run --features rendering`):
- Full DefaultPlugins (windowing, rendering, asset loading)
- 60 FPS with normal time flow
- Player input handling
- 3D visuals and animations

**Headless mode** (`cargo run --no-default-features --features headless`):
- MinimalPlugins only (no graphics)
- Variable FPS based on time scale (sqrt scaling)
- Console output for progress
- Time acceleration via `Time<Virtual>`

The headless setup:

```rust
pub fn run() {
    let time_scale = parse_arg("--time-scale", 10.0);
    
    // Calculate update rate to maintain game time resolution
    // 1x -> 60 FPS, 10x -> 190 FPS, 100x -> 600 FPS, 1000x -> 1897 FPS
    let target_fps = 60.0 * (time_scale as f64).sqrt();
    let update_interval = Duration::from_secs_f64(1.0 / target_fps);
    
    App::new()
        .add_plugins(MinimalPlugins.set(
            ScheduleRunnerPlugin::run_loop(update_interval)
        ))
        .insert_resource(HeadlessArgs { time_scale, .. })
        .add_systems(Startup, setup_headless_mode)
        .run();
}

fn setup_headless_mode(mut time: ResMut<Time<Virtual>>, args: Res<HeadlessArgs>) {
    time.set_relative_speed(args.time_scale);  // Apply time acceleration
    // ...
}
```

The sqrt scaling is important. At 1000x speed, running at 60 FPS would mean each frame simulates 16.7 game seconds—way too coarse. At 1897 FPS (sqrt(1000) * 60), each frame is 0.527 game seconds, maintaining smooth simulation.

Performance examples from testing:
- 1x: ~30s real time for full game (60 FPS)
- 10x: ~3s real time (190 FPS updates)
- 100x: ~0.3s real time (600 FPS updates)
- 1000x: ~1.5s real time (1897 FPS updates)

The game outputs results to CSV for analysis:

```
[TICK 4560] Round 5/5 | Player Food: 4 | Agent Food: 6 | Player Influence: 12 | Agent Influence: 15

===========================================
  GAME OVER (Match 1/100)
===========================================
Winner: Agent
Reason: MaxRounds
Total ticks: 4823
Real time: 1.5 seconds
Game time: 47.8 seconds (1000x acceleration)
===========================================

Results written to results.csv
Starting next match (2/100)...
```

With this setup, I can run 100 AI vs AI matches in under 3 minutes, testing balance changes and AI tuning without manual playtesting. The CSV output includes all game metrics plus the AI configuration parameters, so I can analyze which strategies win most often.

## Code Architecture: Separating Concerns

The headless/rendering split forced better code organization. Previously, everything was tangled together—agent spawning mixed 3D model loading with ECS component setup. Now:

**shared.rs**: Core agent logic (decision making, hunger, state management)
```rust
pub fn spawn_agent_core(commands: &mut Commands, grid: &Grid) -> Entity {
    // Pure ECS logic: components, position, strategy
    // No rendering code
}
```

**rendering.rs**: Rendering-specific (3D models, animations, materials)
```rust
pub fn spawn_agent(/* ... */) {
    let agent_entity = spawn_agent_core(&mut commands, &grid);
    // Add rendering components (SceneRoot, Material, etc.)
}
```

**headless.rs**: Headless-specific (console output, no visuals)
```rust
pub fn spawn_agent(/* ... */) {
    let agent_entity = spawn_agent_core(&mut commands, &grid);
    // No rendering components needed
}
```

The same pattern applied to `main.rs` → `rendering_main.rs` + `headless_main.rs`. Each mode imports only what it needs. Compile times improved (headless doesn't link graphics libraries), and the separation of concerns makes future changes cleaner.

## Visual Polish: GPU Ocean and Falling Leaves

While refactoring, I tackled a performance issue: the ocean animation was running on CPU, updating vertex positions every frame. On mobile, this was killing frame rates.

The fix: move it to a GPU shader. The ocean material now uses a custom WGSL shader that calculates wave positions per-pixel:

```wgsl
fn vertex(vertex: Vertex) -> VertexOutput {
    var position = vertex.position;
    let time = globals.time;
    
    // Multiple sine waves for natural-looking ocean
    position.y += sin(position.x * 0.5 + time * 2.0) * 0.1;
    position.y += sin(position.z * 0.7 + time * 1.5) * 0.08;
    
    // ... transform to clip space
}
```

The GPU handles thousands of vertices in parallel. Frame rate impact: negligible. The ocean still looks alive, but now the CPU is free for AI calculations.

I also added falling leaves as ambient effect—a particle system with leaf meshes slowly drifting down using velocity and gravity. It's purely aesthetic, but it makes the forest biomes feel less static. Sometimes the small touches matter.

<video autoplay loop muted playsinline
       style="display:block; margin-left:auto; margin-right:auto; max-width:100%; height:300px;">
  <source src="{{ '/assets/2025/leaf.webm' | relative_url }}" type="video/webm">
  Your browser does not support the video tag.
</video>


## What's Next?

The game now has functional AI that understands territory, defense, and resource management. It can be tested at extreme speeds in headless mode. The codebase is organized for future expansion.

But there's still work ahead:
- **Balance tuning**: The AI config has 17 parameters (capture weights, threat detection radius, starvation thresholds). Finding optimal values requires analyzing those CSV results.
- **Strategy diversity**: Right now both AIs use the same strategy. Adding personality—aggressive vs defensive, greedy vs efficient—would make matches more interesting.
- **Mobile polish**: The grid alignment issues persist. The AI still runs off-screen on some devices. This needs actual device testing, not just emulator work.
- **The hexagon question**: The game is real-time, but uses a hex grid. The grid exists for influence and pathfinding, but doesn't feel strategic yet. Next step: figure out what the hex grid is actually *for* in this design. Turn-based? Action points? Still working on that one.

For now, the AI is no longer a Roomba. It's a capable opponent that adapts to circumstances, defends when threatened, and makes strategic decisions. Whether it's good enough to challenge a human player long-term remains to be seen. But at least it's trying.

---

*Previous post: [Territory, Time, and Technical Debt](./2025-12-08-territory-time-and-technical-debt.md) | Next post: TBD*
