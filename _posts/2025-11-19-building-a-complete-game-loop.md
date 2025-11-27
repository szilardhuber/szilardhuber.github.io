---
title: "Building a Complete Game Loop: AI-Assisted Development and Years of Procrastination"
date: 2025-11-19
author: Szilard Huber
tags: [bevy, rust, game-dev, ai-coding, pathfinding, procedural-generation]
---

# Building a Complete Game Loop: AI-Assisted Development and Years of Procrastination

I've been working on this hex-grid survival game with Bevy for years—but until recently, progress was glacial. A few commits here, a small feature there, whenever I could find time and motivation. With my progress I was expecting to release somewhere before Christmas of 2153 (If I were lucky). Then something changed: I discovered just how effective AI-assisted coding can be in the hands of an experienced developer. The past month has been a revelation. What used to take me weeks of sporadic evening coding sessions now happens in hours. This isn't about AI writing code for me—it's about amplifying my capabilities as a senior developer, handling boilerplate, suggesting solutions, and letting me focus on architecture and design decisions. The result? More progress in the last 30 days than in the previous year combined. This is the story of how AI coding tools helped me transform a stagnant side project into a genuinely playable cross-platform game.

## Where We Started: A Game That Couldn't Be Played

At the beginning of November, I had the basic building blocks: a hex grid, a fox model that could move, and not much else. The game was more of a tech demo than anything playable. Players could click tiles, but the fox would happily wander off into the ocean or through forests like it was training for an extreme sports competition. There was no goal, no challenge, no reason to keep playing. More frustratingly, the menu system was broken—buttons would appear and disappear at random, as if they were playing hide-and-seek with the player.

The first order of business was making this feel like an actual game. That meant constraints, goals, and a proper game loop. You know, the basics.

## Teaching the Fox to Respect Boundaries

The first major improvement was implementing proper pathfinding. I integrated the `pathfinding` crate and built an A* pathfinding system that respects terrain types. Revolutionary, I know—making a game character not walk through solid objects.

The implementation in `pathfinding.rs` is elegantly simple: each terrain type has a cost (grass costs 1, sand costs 2, ocean and woods are impassable), and we use Manhattan distance as our heuristic. What makes it feel polished is the visual feedback—when you click a tile, a red highlight shows exactly where the fox will end up. No more clicking on the other side of a forest and wondering why your fox has suddenly developed a philosophical stance against movement.

```rust
pub fn find_path(grid: &Grid, start: HexCoord, end: HexCoord) -> Option<(Vec<HexCoord>, u32)> {
    let result = astar(
        &start,
        |p| {
            // Generate successors based on terrain costs
            let mut successors = Vec::new();
            for neighbor_hex in p.neighbors() {
                // ... check bounds and terrain traversability
            }
            successors
        },
        |p| {
            // Manhattan distance heuristic for hex grids
            (((p.q - end.q).abs() + (p.r - end.r).abs() + (p.s - end.s).abs()) / 2) as u32
        },
        |p| *p == end,
    );
    result
}
```

This simple addition transformed the feel of the game. The fox now feels smart, navigating around obstacles naturally. Or at least, it pretends to be smart. Close enough.

## Bringing the World to Life with Perlin Noise

Random terrain generation was next on the list, but I didn't want completely random noise—I wanted organic-looking continents with proper beaches and forests. Because apparently, my standards for a game I have no idea at this point what would be about are "natural-looking geography." Enter Perlin noise.

The map generation system in `grid.rs` uses the `noise` crate to create natural-looking terrain distributions. A single Perlin noise sample determines whether each hex becomes ocean, sand, grass, or woods based on threshold values. But here's the catch: not every random map is playable. Turns out, generating a beautiful island where the player spawns completely surrounded by ocean with no way to reach food is... bad game design.

I built a validation system that ensures two critical properties:
1. **Connectivity**: Every traversable tile (grass and sand) must be reachable from every other traversable tile
2. **Balance**: The map must have reasonable percentages of each terrain type (30-80% grass, 5-30% sand, etc.)

The generator attempts up to 100 maps before giving up, and in practice, it usually finds a valid one within 2-3 attempts. This was a great reminder that procedural generation isn't just about randomness—it's about constrained randomness that creates fun, playable spaces.

To make the world feel more alive, I added texture variety (four different grass textures, two forest variants) and spawned actual 3D tree models on forest tiles. Each forest hex gets 2-5 randomly scaled and rotated trees, giving the world much-needed vertical interest.

## Building a Survival Game

With solid terrain and movement, it was time to add SOME game logic. I implemented a hunger system: the fox has 10 seconds before it starves, and the only way to survive is to collect food. Food cubes (yes, magenta cubes—art is definitely not my strong suit) spawn randomly on traversable tiles every 1-3 seconds and despawn after 10 seconds if not collected.

The food system in `food.rs` is simple but effective. It maintains a set of currently occupied coordinates to avoid spawning multiple food items on the same tile, and the despawn timer creates natural urgency. When the fox reaches a food tile, it instantly eats it, resetting the hunger timer and incrementing the score.

This created the core gameplay loop: watch for food spawns, plot efficient paths to reach them before they despawn, manage your hunger timer. It's simple, but it works. Which is honestly surprising given everything else that went wrong this month.

## The State Management Nightmare

Everything was working beautifully until I tried to restart the game. Click "New Game" and... crash. Or worse, the game would restart but behave strangely—old food would persist, the camera would be in the wrong place, or the player would spawn in a weird location. You know, just classic game development things.

The problem was entity lifecycle management. Bevy's ECS (Entity Component System) is powerful but unforgiving when you don't clean up properly. When transitioning from `Playing` to `GameOver` and back to `Playing`, I wasn't properly despawning entities, leading to zombie food cubes and duplicate players haunting the scene. Turns out, having two foxes spawn on top of each other, both responding to clicks, creates what I can only describe as "interpretive dance choreography." Not the gameplay experience I was going for.

The solution required a comprehensive cleanup and reset architecture:

1. **Marker Components**: I added `SceneLight` and `SceneSky` markers to track which entities belong to the game scene
2. **Cleanup Systems**: Each plugin now has an `OnExit(GameState::Playing)` system that uses `despawn_recursive()` to properly remove entity hierarchies
3. **Reset Systems**: An `OnEnter(GameState::Playing)` system resets all game state—score back to 0, hunger timer reset, spawn flags cleared
4. **Camera Persistence**: The camera was particularly tricky. It needed to persist through the `Playing → GameOver` transition (otherwise the Game Over UI wouldn't render), but it also needed to be re-centered when starting a new game

The key insight was that state transitions in Bevy require thinking about the entire entity graph, not just individual components. When you spawn a player with children (like the fox's scene graph), you need `despawn_recursive()`, not just `despawn()`. Learned that lesson after creating approximately 47 ghost foxes that continued to exist in some quantum superposition state.

## What I Learned

This month taught me several valuable lessons about game development in Bevy (mostly through painful trial and error):

**State Management is Critical**: In ECS architectures, you can't just transition states and hope for the best. Every entity that gets spawned needs an exit strategy. Every resource that gets modified needs a reset path. The game loop isn't just about what happens during play—it's about clean transitions between states.

**Procedural Generation Needs Validation**: Rule-based random map generation wasn't good enough and using existing algorithms like Perlin noise is not overcomplication. The validation system prooved to be simple enough but still ensures every single map is playable.

**Start Simple, Add Complexity**: The fox-and-food survival loop is incredibly simple, but it's complete. It has a goal, failure states, and emergent strategy (efficient pathing vs. playing it safe). Also by the time of writing this post I already have a game concept in mind that I would be happy to play with. Which is to be hones the main point of this experiment. (Besides using game development as an excuse to learn Rust, Bevy, AI Coding, Marketing, iOS Publishing and all kind of stuff)

## What's Next?

The game is now genuinely playable, which feels weird to say about something I started years ago. Some ideas AI is giving me for future updates (spoiler alert, this will not be the actual way forward I'm just writing it here as a memento on how important human touch is with AI coding at the moment):

- **Multiple fox types**: Different animals with unique movement patterns
- **Power-ups**: Temporary speed boosts or hunger timer extensions  
- **Procedural obstacles**: Dynamic terrain changes during gameplay
- **Leaderboards**: Persistent high scores across sessions
- **Audio polish**: Better sound effects for movement, eating, and game over
- **Making the fox not walk through trees**: This one's aspirational

---
