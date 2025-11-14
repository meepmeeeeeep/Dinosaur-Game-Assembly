# Developer Guide - Advanced Topics

Advanced customization and development guide for the Dinosaur Game Assembly project.

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [Game Loop](#game-loop)
- [Adding New Obstacles](#adding-new-obstacles)
- [Creating New Mechanics](#creating-new-mechanics)
- [Performance Optimization](#performance-optimization)
- [Debugging Tips](#debugging-tips)
- [Common Issues](#common-issues)

---

## Architecture Overview

### Memory Layout
```
.DATA Section
├── Game State Variables (score, isOver, isPaused)
├── Object Positions (obj1x, obj2x, obj3x, etc.)
├── Physics Variables (speeds, cooldowns, jump states)
├── Lane Configuration (positions, ceilings, grounds)
└── Visual Settings (colors, blink states)

.CODE Section
├── Main Game Loop (GamePlay)
├── Initialization (GameInit, GameRestart)
├── Rendering (makeScreen0, makeScreen2, drawClouds)
├── Physics (jump mechanics, collision detection)
├── Sprite Drawing (BasicBlit, BasicBlitDino)
└── Utilities (random generation, scoring)
```

### Execution Flow
```
Program Start
    ↓
GameInit (setup)
    ↓
Screen 0 (instructions) ← Wait for SPACE
    ↓
Screen 1 (transition animation)
    ↓
Screen 2 (main game) ← Game Loop
    ├→ Input Processing
    ├→ Physics Update
    ├→ Collision Detection
    ├→ Rendering
    └→ Check Game Over
         ↓
Screen 3 (game over) ← Wait for SPACE → GameRestart
```

---

## Game Loop

### Main Loop Structure (makeScreen2)

```assembly
makeScreen2 PROC
    ; 1. SPRITE SELECTION
    ; Choose which frame of animation to display
    
    ; 2. LANE SWITCHING
    ; Check W/S keys, apply cooldown
    
    ; 3. MOVEMENT INPUT
    ; Process jump/duck/run states
    
    ; 4. PHYSICS UPDATE
    ; Apply gravity, velocity, collision
    
    ; 5. OBSTACLE UPDATE
    ; Move obstacles, check offscreen, respawn
    
    ; 6. RENDERING
    ; Draw all game elements
    
    ; 7. SCORE/STATE UPDATE
    ; Increment score, check milestones
    
    ret
makeScreen2 ENDP
```

### Frame-by-Frame Execution

Every frame (approximately 60 FPS):
1. Clear screen (makeWhiteScreen)
2. Update game state (makeScreen2)
3. Draw all elements
4. Check collisions
5. Handle input for next frame

---

## Adding New Obstacles

### Step 1: Define Data Structure

```assembly
.DATA
; New obstacle variables
new_obstacle_x DWORD 890        ; X position
new_obstacle_y DWORD 300        ; Y position  
new_obstacle_speed DWORD 21     ; Movement speed
new_obstacle_mode DWORD 0       ; Variation (if multiple types)
```

### Step 2: Create Sprite

In `bitmaps.asm`:
```assembly
new_obstacle DINOGAMEBITMAP <width, height, transparent_color,, offset new_obstacle + sizeof new_obstacle>
    BYTE ...  ; Bitmap data here
```

### Step 3: Add Movement Logic

In `makeScreen2`:
```assembly
move_new_obstacle:
    cmp new_obstacle_x, -30
    jle obstacle_offscreen
    
    mov ebx, new_obstacle_speed
    sub new_obstacle_x, ebx
    cmp new_obstacle_x, 670
    jge skip_draw
    
draw_new_obstacle:
    INVOKE BasicBlit, OFFSET new_obstacle, new_obstacle_x, new_obstacle_y
    jmp next_section

obstacle_offscreen:
    ; Respawn logic
    INVOKE generateStartPos
    mov new_obstacle_x, eax
```

### Step 4: Add Collision Detection

In `BasicBlitDino`:
```assembly
; Check collision with new obstacle
INVOKE CheckIntersect, dino_x, dino_y, dino_bitmap, new_obstacle_x, new_obstacle_y, OFFSET new_obstacle
cmp eax, 1
je collision_detected
```

### Step 5: Initialize in GameRestart

```assembly
GameRestart PROC
    ; ... existing code ...
    
    INVOKE randInt, 800, 1200
    mov new_obstacle_x, eax
    
    ret
GameRestart ENDP
```

---

## Creating New Mechanics

### Example: Triple Jump

#### 1. Add Variables
```assembly
.DATA
jumps_remaining DWORD 3         ; Changed from 2 to 3
triple_jump_bonus DWORD 0       ; Bonus points for triple jump
```

#### 2. Modify Jump Logic
```assembly
check_triple_jump:
    cmp KeyPress, VK_SPACE
    je try_triple_jump
    cmp KeyPress, VK_UP
    jne jump

try_triple_jump:
    cmp jumps_remaining, 0
    je jump
    
    ; Award bonus on third jump
    cmp jumps_remaining, 1
    jne normal_jump
    add score, 50               ; Bonus points!
    
normal_jump:
    dec jumps_remaining
    mov obj1_going_down, 0
    invoke PlaySound, offset jump_sound, 0, SND_FILENAME OR SND_ASYNC
    jmp jump
```

### Example: Power-Up System

#### 1. Define Power-Up Structure
```assembly
.DATA
powerup_x DWORD 800
powerup_y DWORD 250
powerup_active DWORD 1
powerup_type DWORD 0            ; 0=speed boost, 1=invincibility
powerup_duration DWORD 0        ; Frames remaining

invincible_mode DWORD 0         ; 1 if invincible
```

#### 2. Spawn Power-Up
```assembly
spawn_powerup:
    cmp score, 500
    jl no_powerup
    
    INVOKE randInt, 0, 2
    mov powerup_type, eax
    
    INVOKE randInt, 700, 900
    mov powerup_x, eax
    mov powerup_active, 1
```

#### 3. Collision with Power-Up
```assembly
check_powerup_collision:
    cmp powerup_active, 0
    je no_powerup_collision
    
    INVOKE CheckIntersect, obj1x, obj1y, dino_bitmap, powerup_x, powerup_y, OFFSET powerup_sprite
    cmp eax, 1
    jne no_powerup_collision
    
    ; Activate power-up
    mov powerup_active, 0
    mov powerup_duration, 300   ; 5 seconds at 60 FPS
    
    cmp powerup_type, 0
    je speed_boost
    mov invincible_mode, 1
    jmp no_powerup_collision
    
speed_boost:
    sub cactus_speed, 10        ; Slow down obstacles
```

#### 4. Update Power-Up
```assembly
update_powerup:
    cmp powerup_duration, 0
    je no_active_powerup
    
    dec powerup_duration
    cmp powerup_duration, 0
    jne no_active_powerup
    
    ; Deactivate power-up
    mov invincible_mode, 0
    add cactus_speed, 10        ; Restore speed
```

---

## Performance Optimization

### 1. Minimize Memory Access

**Bad**:
```assembly
mov eax, [score]
add eax, 1
mov [score], eax
mov ebx, [score]    ; Unnecessary memory read
```

**Good**:
```assembly
mov eax, [score]
inc eax
mov [score], eax
mov ebx, eax        ; Use register value
```

### 2. Use Appropriate Instructions

**Slower**:
```assembly
mov eax, 0          ; 5 bytes
add eax, 1          ; 3 bytes
```

**Faster**:
```assembly
xor eax, eax        ; 2 bytes, faster
inc eax             ; 1 byte, faster
```

### 3. Reduce Conditional Branches

**Less Efficient**:
```assembly
cmp eax, 0
je zero_case
cmp eax, 1
je one_case
cmp eax, 2
je two_case
; etc.
```

**More Efficient** (for many cases):
```assembly
; Use jump table
mov ebx, eax
shl ebx, 2          ; multiply by 4 (DWORD size)
jmp [jump_table + ebx]
```

### 4. Cache Frequently Used Values

```assembly
; Store in register for repeated use
mov esi, obj1x      ; Cache position
mov edi, obj1y

; Use cached values
add esi, 5
add edi, 3
INVOKE DrawPixel, esi, edi, color
```

---

## Debugging Tips

### 1. Visual Debugging

Add colored markers:
```assembly
; Mark specific game state
cmp game_state, DEBUG_STATE
jne normal_operation
INVOKE DrawLine, 0, 240, 640, 240, 255  ; Red line across screen
```

### 2. Value Display

```assembly
; Display variable values
INVOKE PrintDWORD, debug_value, 10, 10, 255
INVOKE PrintDWORD, another_value, 10, 20, 255
```

### 3. Breakpoints with Sound

```assembly
; Audio indicator when reaching code
cmp debug_flag, 1
jne skip_debug
invoke PlaySound, offset debug_sound, 0, SND_FILENAME OR SND_ASYNC
skip_debug:
```

### 4. State Logging

```assembly
; Log state changes
mov eax, current_state
cmp eax, last_state
je no_state_change
mov last_state, eax
; Add visual/audio indicator
INVOKE DrawStr, OFFSET state_msg, 10, 30, 0
no_state_change:
```

---

## Common Issues

### Issue 1: Objects Not Appearing

**Symptoms**: Sprite defined but doesn't render

**Checklist**:
1. Is bitmap properly defined in `bitmaps.asm`?
2. Is position within screen bounds (0-640, 0-480)?
3. Is transparent color correct?
4. Is `INVOKE BasicBlit` being called?
5. Is object X position > 670 (offscreen right)?

**Debug**:
```assembly
; Verify position
INVOKE PrintDWORD, obj_x, 10, 100, 0
INVOKE PrintDWORD, obj_y, 10, 110, 0
```

### Issue 2: Collision Not Working

**Symptoms**: Player passes through obstacles

**Common Causes**:
1. Not using `BasicBlitDino` for player sprite
2. Incorrect transparent color value
3. Objects drawn after collision check
4. Hitbox size mismatch

**Fix**:
```assembly
; Ensure proper order
1. Move objects
2. Check collisions
3. Draw sprites

; Verify collision check exists
INVOKE CheckIntersect, dino_x, dino_y, dino_bitmap, obstacle_x, obstacle_y, obstacle_bitmap
cmp eax, 1
je handle_collision
```

### Issue 3: Speed Issues

**Symptoms**: Game too fast/slow, inconsistent

**Solutions**:
```assembly
; Use frame-independent timing
mov eax, frame_time
imul eax, base_speed
sar eax, 16             ; Convert from fixed-point

; Cap maximum speed
cmp current_speed, max_speed
jle speed_ok
mov current_speed, max_speed
speed_ok:
```

### Issue 4: Memory Corruption

**Symptoms**: Crashes, unexpected values

**Prevention**:
```assembly
; Always initialize variables
mov variable, 0

; Clear registers before use
xor eax, eax

; Match PUSH/POP
push eax
; ... code ...
pop eax         ; Must match!

; Use USES directive
MyProc PROC USES eax ebx ecx
    ; Registers auto-saved
    ret
MyProc ENDP
```

### Issue 5: Jump Table

**Creating Efficient State Machines**:

```assembly
.DATA
state_table DWORD state_0, state_1, state_2, state_3

.CODE
; Jump based on state
mov ebx, current_state
cmp ebx, 3
ja invalid_state        ; Bounds check!
shl ebx, 2              ; * 4 (DWORD)
jmp [state_table + ebx]

state_0:
    ; Handle state 0
    jmp end_states
state_1:
    ; Handle state 1
    jmp end_states
; etc.
invalid_state:
    ; Handle error
end_states:
```

---

## Advanced Techniques

### Fixed-Point Math

For precise sub-pixel movement:
```assembly
; Use 16.16 fixed-point (16 bits integer, 16 bits decimal)
.DATA
velocity DWORD 00010000h    ; 1.0 in fixed-point

; Add velocity
mov eax, position
add eax, velocity
mov position, eax

; Convert to pixel (integer part only)
sar eax, 16
mov pixel_x, eax
```

### Interpolation

Smooth transitions:
```assembly
; Linear interpolation
; result = start + (end - start) * t
mov eax, end_value
sub eax, start_value
imul eax, t_value       ; t in 0-65536 (0.0 to 1.0)
sar eax, 16
add eax, start_value
```

### Particle System

```assembly
.DATA
MAX_PARTICLES EQU 50
particles PARTICLE MAX_PARTICLES DUP(<>)

; Update all particles
mov ecx, MAX_PARTICLES
mov esi, OFFSET particles
particle_loop:
    ; Update position
    mov eax, (PARTICLE PTR [esi]).x
    add eax, (PARTICLE PTR [esi]).vx
    mov (PARTICLE PTR [esi]).x, eax
    
    ; Next particle
    add esi, SIZEOF PARTICLE
    loop particle_loop
```

---

## Testing Checklist

- [ ] All obstacles spawn correctly
- [ ] Collision detection works in all lanes
- [ ] Jump mechanics feel responsive
- [ ] Speed scaling is balanced
- [ ] No memory leaks or crashes
- [ ] Sound effects play correctly
- [ ] Score increments properly
- [ ] High score saves/loads
- [ ] Night mode transitions smoothly
- [ ] Controls are responsive
- [ ] Game over screen displays
- [ ] Restart works correctly
- [ ] Pause functionality works
- [ ] Pterodactyl toggle works
- [ ] Lane switching has proper cooldown

---

For basic concepts, see [Assembly_Commands.md](Assembly_Commands.md)

For user guide, see [README.md](README.md)