# **Goal-Oriented Action Planning for Godot 4.**  Goal Oriented Action Planning implementation for Godot 
# Version 0.1 beta.  Do *not* base any project on this as there's probably a ton of bugs i haven't come across.


## Features

- AStar planner that works backwards from the goal through preconditions and effects
- `GoapAgent2D` and `GoapAgent3D` with built-in `NavigationAgent` movement and smooth turning
- Goals re-evaluated every plan tick, so higher-priority goals can interrupt the current plan
- Plans that heal themselves: invalid actions or plans are dropped and re-planned
- Per-action goto positions, including moving targets (my main disign differnece from F.E.A.R)
- Component dictionary to keep actions generic and allow integration with your game systems (one `shoot` action can use the refrence the dictionary holds as `weapon`)
- Built-in "eyes" sysrem for agents to detect specific node groups and methods to refrence them (tip: use two sets of eyes - a frustum one for moving targets - and a spherical one for static objects to mimick object permanance). Eyes currently have no line-of-sight but will be added soon.


## Installation

1. Copy the plugin to `res://addons/godot_goap_enemies/`.
2. Enable it under **Project → Project Settings → Plugins**.


## Usage

- Install the plugin
- Make your first `GoapAction`s and `GoapGoal`s
- Register them with their unique name as key in the dictionaries in `res://addons/godot_goap_enemies/goap_library.gd`
- Give your `GoapAgent` the goals and actions you want it to have
- The `GoapAgent` will now plan and do the series of actions to complete the goal, if that is possible


## Use of AI

**Nope** there's no ai used


## Future Plans

**This plugin is made for my own game and will be developed alongside it for my needs, but of course ideas and PRs are welcome**

*Features I'm planning to add:*
- SmartObject Actions
- Better "Target" system for the agent eyes, that will keep track of distance and awareness
- ActionSet and GoalSet Resources to be saved and shared between agent, along with per-agent specific bias for costs
- Actually release this on the godot asset store

## License
Don't really know how they work but this is free to use or fork for any use.
