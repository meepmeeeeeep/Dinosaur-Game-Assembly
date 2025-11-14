# Dinosaur Game - Assembly x86 Project

A Chrome Dinosaur Game clone written in x86 Assembly language with advanced features including multi-lane gameplay, double jumping, and dynamic difficulty scaling.

## Table of Contents
- [Getting Started](#getting-started)
- [Game Features](#game-features)
- [Controls](#controls)
- [Game Mechanics](#game-mechanics)
- [Customization Guide](#customization-guide)
- [File Structure](#file-structure)
- [For Developers](#for-developers)

## Getting Started

### Prerequisites
- MASM32 SDK
- Windows operating system
- Basic understanding of Assembly language (see [Assembly_Commands.md](Assembly_Commands.md))

### Building the Project
1. Open command prompt in project directory
2. Run the build script or use MASM32 to compile
3. Execute the resulting `.exe` file

## Game Features

### Core Features
- **Multi-Lane System**: Three lanes (top, middle, bottom) for strategic gameplay
- **Double Jump**: Jump twice in mid-air for precise obstacle avoidance
- **Fast Fall**: Hold DOWN or CTRL to fall faster
- **Jump Cancellation**: Press DOWN during jump to start falling early
- **Dynamic Speed**: Obstacles get faster every 200 points
- **Night Mode**: Background alternates between day/night every 1000 points
- **Easter Egg**: Rainbow text effect when score reaches 10000-11000

### Visual Features
- Day/Night cycle with color inversion
- Animated dinosaur sprites
- Flying pterodactyls (can be disabled)
- Randomly generated cloud patterns
- Moving ground effect

## Controls

| Key | Action |
|-----|--------|
| **SPACE** / **UP** | Jump / Start Game |
| **W** | Switch to upper lane |
| **S** | Switch to lower lane |
| **DOWN** / **CTRL** | Duck / Fast Fall / Cancel Jump |
| **RIGHT** | Pause game |
| **LEFT** | Toggle pterodactyls on/off |

## Game Mechanics

### Lane Switching
- **Cooldown**: 2 frames between switches
- **Three Lanes**: Top (Y=200), Middle (Y=300), Bottom (Y=400)
- Cannot switch beyond top/bottom lanes

### Jumping System
- **Jump Height**: 120 pixels from ground
- **Upward Speed**: 30 pixels/frame
- **Normal Fall**: 30 pixels/frame
- **Fast Fall**: 45 pixels/frame (when holding DOWN/CTRL)
- **Double Jump**: 
  - Allows second jump in mid-air
  - Input cooldown: 6 frames
  - Jump cooldown: 2 frames
  - Resets when landing

### Scoring System
- **Base Score**: Increases by 1 per frame (only when pterodactyls enabled)
- **Score Milestones**:
  - Every 100 points: Level up sound
  - Every 1000 points: Background color changes + score blinks
  - 10000-11000: Rainbow text easter egg

### Difficulty Scaling
- **Speed Increase**: Every 200 points
- **Increment**: +2 speed per milestone
- **Max Speed**: Caps at 4000 points
- **Base Speeds**:
  - Cactus: 21 → 41 (max)
  - Pterodactyl: 28 → 48 (max)

### Obstacle Generation
- **Cacti**: Three lanes with randomized positions
- **Pterodactyls**: Three height variations, can be toggled off
- **Spacing**: Minimum 400 pixels between obstacles
- **Randomization**: Start positions vary each game

## Customization Guide

### Adjusting Speed
Located in `game.asm` `.DATA` section:
```assembly
base_obj2_speed DWORD 28      ; Base bird speed
base_cactus_speed DWORD 21    ; Base cactus speed
speed_increment DWORD 2       ; Speed increase per milestone
max_speed_multiplier DWORD 20 ; Speed cap (200 * 20 = 4000 points)
```

### Modifying Jump Physics
Located in `game.asm` jump mechanics section:
```assembly
; Jump speeds
sub obj1y_jump, 30    ; Upward speed (increase = faster climb)
add obj1y_jump, 30    ; Normal fall speed
add obj1y_jump, 45    ; Fast fall speed

; Jump heights
lane_ceiling DWORD 80, 180, 280   ; Max heights per lane
lane_ground DWORD 200, 300, 400   ; Ground levels per lane
```

### Lane Positions
Located in `game.asm` `.DATA` section:
```assembly
lane_y DWORD 200, 300, 400        ; Y positions for lanes
top_lane_y DWORD 200              ; Top lane position
bottom_lane_y DWORD 400           ; Bottom lane position
```

### Cooldown Timings
Located in `game.asm` `.DATA` section:
```assembly
lane_switch_cooldown DWORD 2           ; Lane switch delay
double_jump_input_cooldown DWORD 6     ; Double jump input delay
double_jump_cooldown DWORD 2           ; Between jumps delay
pterodactyl_cooldown DWORD 15          ; Pterodactyl toggle delay
game_over_cooldown DWORD 15            ; Restart delay
```

### Color Schemes
Located in `game.asm` `makeWhiteScreen` procedure:
```assembly
; Day mode
mov eax, 255    ; White background

; Night mode
mov eax, 110    ; Gray background (adjust for different shade)
```

### Sound Effects
Located in `game.asm` `.DATA` section:
```assembly
jump_sound BYTE "jump_sound.wav", 0
dead_sound BYTE "dead_sound.wav", 0
level_up_sound BYTE "level_up_sound.wav", 0
```
Replace `.wav` files in project directory to change sounds.

## File Structure

```
Dinosaur Game/
├── game.asm           # Main game logic
├── blit.asm          # Drawing and rendering functions
├── bitmaps.asm       # Sprite data
├── trig.asm          # Trigonometry functions
├── stars.asm         # Star field rendering
├── lines.asm         # Line drawing functions
├── *.inc             # Include files with definitions
├── *.wav             # Sound effect files
└── docs/
    ├── README.md              # This file
    ├── Assembly_Commands.md   # Assembly reference
    └── Developer_Guide.md     # Advanced customization
```

## For Developers

### Key Procedures
- `GamePlay`: Main game loop
- `GameInit`: Initialize game state
- `GameRestart`: Reset for new game
- `makeScreen2`: Render game frame
- `CheckIntersect`: Collision detection
- `BasicBlitDino`: Draw dinosaur with collision
- `BasicBlit`: Draw sprites without collision

### Important Variables
- `score`: Current score
- `highScore`: Best score
- `current_lane`: Active lane (0=top, 1=middle, 2=bottom)
- `obj1_going_down`: Jump direction flag
- `jumps_remaining`: Double jump counter
- `is_night_mode`: Day/night toggle
- `isOver`: Game over flag
- `isPaused`: Pause state

### Adding New Features
1. Define variables in `.DATA` section
2. Add logic in `makeScreen2` procedure
3. Update collision detection if needed
4. Test thoroughly with different scenarios

For detailed Assembly command reference, see [Assembly_Commands.md](Assembly_Commands.md)

For advanced development topics, see [Developer_Guide.md](Developer_Guide.md)

## Credits

Based on the Chrome Dinosaur Game by Google.
Developed as an educational Assembly language project.