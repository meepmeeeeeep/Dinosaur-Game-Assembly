; #########################################################################
;
;   game.asm - Assembly file for EECS205 Assignment 5
;
; #########################################################################

.586
.MODEL FLAT,STDCALL
.STACK 4096
option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc
include game.inc

;; Has keycodes
include keys.inc
;; sounds/ music
include \masm32\include\windows.inc
include \masm32\include\winmm.inc
includelib \masm32\lib\winmm.lib
;; number printing
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib
;; random
include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib

.DATA
;; If you need to, you can place global variables here
instruct0 BYTE "DINOSAUR GAME", 0
instruct1 BYTE "Press SPACE / UP ARROW to jump.", 0
instruct2 BYTE "Use DOWN ARROW to duck.", 0
instruct3 BYTE "Use RIGHT to pause game.", 0
instruct4 BYTE "Use LEFT to disable / enable pterodactyls.", 0
instruct5 BYTE "Press SPACE to start the game.", 0

pausedStr BYTE "G A M E  P A U S E D", 0

endStr BYTE "G A M E  O V E R", 0
restartStr BYTE "Press SPACE to restart the game.", 0

birdStr0 BYTE "PTERODACTYLS ENABLED", 0
birdStr1 BYTE "PTERODACTYLS DISABLED", 0

fmtStr0 BYTE "%d", 0
fmtStr1 BYTE "0%d", 0
fmtStr2 BYTE "00%d", 0
fmtStr3 BYTE "000%d", 0
fmtStr4 BYTE "0000%d", 0
fmtStr0_high BYTE "HI %d", 0
fmtStr1_high BYTE "HI 0%d", 0
fmtStr2_high BYTE "HI 00%d", 0
fmtStr3_high BYTE "HI 000%d", 0
fmtStr4_high BYTE "HI 0000%d", 0
outStr BYTE 256 DUP(0)
blankStr BYTE "%d", 0

;; score keeping
paused DWORD 0	;; 1 if paused, 0 otherwise
score DWORD 0
highScore DWORD 0
;; LOCATION of OBJECT 1: dinosaur
obj1x DWORD 40
obj1y_run DWORD 300
obj1y_duck DWORD 318
obj1y_jump DWORD 300
obj1_going_down DWORD 0

obj1_mode DWORD 0	;; for animating dino: running=0, ducking=1, jumping=2
obj1_run DWORD 0 	;; for incrementing through the 3 stages of running
obj1_duck DWORD 0 	;; for incrementing through the 2 stages of ducking
;; LOCATION of OBJECT 2: bird
obj2_disabled DWORD 0
obj2x DWORD 1870
obj2y_high DWORD 260
obj2y_mid DWORD 275
obj2y_low DWORD 300
obj2_mode DWORD 0	;; keeps track of which mode we are on
obj2 DWORD 0		;; for the two stages of flying
;; LOCATION of OBJECT 3: cactus
obj3x DWORD 890
obj3_mode DWORD 0 				;; which cactus are we ddrawing????
;;obj3y DWORD 310				;; const

;; LOCATION of OBJECT 4: cactus
obj4x DWORD 1770
obj4_mode DWORD 0 				;; which cactus are we ddrawing????

;; moving background
cloud1x DWORD 670
cloud1y DWORD ?
cloud2x DWORD 883
cloud2y DWORD ?
cloud3x DWORD 1096
cloud3y DWORD ?

ground0x DWORD 519
ground1x DWORD 1557

screen2box DWORD 395
;; speed
obj2_speed DWORD 28
cactus_speed DWORD 21
cloud_speed DWORD 1

;; screen
screenNum DWORD 0
isPaused DWORD 0
isOver DWORD 0

;; sound effects
; SndPath BYTE "Off Limits.wav",0 ; Disabled Music
jump_sound BYTE "jump_sound.wav", 0
dead_sound BYTE "dead_sound.wav", 0
level_up_sound BYTE "level_up_sound.wav", 0

;; score blinker
score_blink_counter DWORD 0    ; Counter for blink duration
score_blink_state DWORD 0      ; 0 = visible, 1 = hidden
score_blink_active DWORD 0     ; 1 if blinking is active

;; Top lane positions
top_lane_y DWORD 200    ; Y position for top lane
top_cactus_x DWORD 890  ; X position for top lane cactus
top_bird_x DWORD 1870   ; X position for top lane bird
top_obj_mode DWORD 0    ; Which object is active in top lane

;; Bottom lane positions
bottom_lane_y DWORD 400  ; Y position for bottom lane
bottom_cactus_x DWORD 1300  ; X position for bottom lane cactus
bottom_bird_x DWORD 2100    ; X position for bottom lane bird
bottom_obj_mode DWORD 0     ; Which object is active in bottom lane

current_lane DWORD 1    ; 0 = top, 1 = middle, 2 = bottom
lane_y DWORD 200, 300, 400  ; Y positions for each lane

lane_ceiling DWORD 80, 180, 280  ; Ceiling heights relative to each lane (120 units up from base)
lane_ground DWORD 200, 300, 400  ; Ground heights for each lane

lane_switch_cooldown DWORD 0    ; Counter for lane switch cooldown
lane_cooldown_time DWORD 2     ; How many frames to wait before next switch

.CODE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;; PRINTING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This prints the score
PrintHighScore PROC USES eax
	mov eax, highScore
	push eax

four_zeros:
	cmp eax, 10
	jge three_zeros
	push offset fmtStr4_high
	jmp print_score

three_zeros:
	cmp eax, 100
	jge two_zeros
	push offset fmtStr3_high
	jmp print_score

two_zeros:
	cmp eax, 1000
	jge one_zero
	push offset fmtStr2_high
	jmp print_score

one_zero:
	cmp eax, 10000
	jge no_zeros
	push offset fmtStr1_high
	jmp print_score

no_zeros:
	push offset fmtStr0_high

print_score:
	push offset outStr
	call wsprintf
	add esp, 12
	invoke DrawStr, offset outStr, 510, 5, 0
	ret
PrintHighScore ENDP
PrintScore PROC USES eax
	mov eax, score
	push eax

four_zeros:
	cmp eax, 10
	jge three_zeros
	push offset fmtStr4
	jmp print_score

three_zeros:
	cmp eax, 100
	jge two_zeros
	push offset fmtStr3
	jmp print_score

two_zeros:
	cmp eax, 1000
	jge one_zero
	push offset fmtStr2
	jmp print_score

one_zero:
	cmp eax, 10000
	jge no_zeros
	push offset fmtStr1
	jmp print_score

no_zeros:
	push offset fmtStr0

print_score:
	push offset outStr
	call wsprintf
	add esp, 12
	invoke DrawStr, offset outStr, 582, 5, 0
	ret
PrintScore ENDP
; This prints digits
PrintDWORD PROC USES eax d_word: DWORD, x_coord: DWORD, y_coord: DWORD, color: DWORD
	mov eax, d_word
	push eax
	push offset blankStr
	push offset outStr
	call wsprintf
	add esp, 12
	invoke DrawStr, offset outStr, x_coord, y_coord, color
	ret
PrintDWORD ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;CHECK COLLISION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; returns 0 if there is no intersect, 1 if there is a collison
CheckIntersect PROC USES ebx ecx edx oneX:DWORD, oneY:DWORD, oneBitmap:PTR DINOGAMEBITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR DINOGAMEBITMAP 
	LOCAL left1:DWORD, right1:DWORD, top1:DWORD, bottom1:DWORD, left2:DWORD, right2:DWORD, top2:DWORD, bottom2:DWORD
	;; left 	DWORD ? ;; x - bitmap.width / 2
	;; right	DWORD ? ;; x + bitmap.width / 2
	;; top 		DWORD ? ;; y - bitmap.height / 2
	;; bottom 	DWORD ? ;; y + bitmap.height / 2
	mov ebx, oneBitmap 	; store first bitmap ptr
	mov edx, twoBitmap  ; store second bitmap ptr
;;SETTING LEFT RIGHT BOUNDS FOR BITMAP 1
	mov eax, (DINOGAMEBITMAP PTR [ebx]).dwWidth
	sar eax, 1 			;eax = width/2
	mov ecx, oneX 		;ecx = oneX
	sub ecx, eax 		;ecx = oneX - (width / 2)
	mov left1, ecx 		;leftBound = oneX - (width / 2)
	mov right1, ecx 	;rightBound = oneX - (width / 2)
	mov eax, (DINOGAMEBITMAP PTR [ebx]).dwWidth
	add right1, eax  	;rightBound = oneX + (width / 2)
;; SETTING LEFT RIGHT BOUNDS FOR BITMAP 2
	mov eax, (DINOGAMEBITMAP PTR [edx]).dwWidth
	sar eax, 1 			;eax = width/2
	mov ecx, twoX 		;ecx = oneX
	sub ecx, eax 		;ecx = oneX - (width / 2)
	mov left2, ecx 		;leftBound = oneX - (width / 2)
	mov right2, ecx 	;rightBound = oneX - (width / 2)
	mov eax, (DINOGAMEBITMAP PTR [edx]).dwWidth
	add right2, eax  	;rightBound = oneX + (width / 2)
;; SETTING TOP BOTTOM BOUNDS FOR BITMAP 1
	mov eax, (DINOGAMEBITMAP PTR [ebx]).dwHeight
	sar eax, 1 			;eax = height/2
	mov ecx, oneY 		;eax = oneY
	sub ecx, eax 		;ecx = oneY - (height / 2)
	mov top1, ecx 		;upperBound = oneY - (height / 2)
	mov bottom1, ecx 	;lowerBound = oneY - (height / 2)
	mov eax, (DINOGAMEBITMAP PTR [ebx]).dwHeight
	add bottom1, eax  	;lowerBound = oneY + (height / 2)
;; SETTING TOP BOTTOM BOUNDS FOR BITMAP 2
	mov eax, (DINOGAMEBITMAP PTR [edx]).dwHeight
	sar eax, 1 			;eax = height/2
	mov ecx, twoY 		;eax = twoY
	sub ecx, eax 		;ecx = twoY - (height / 2)
	mov top2, ecx 		;upperBound = twoY - (height / 2)
	mov bottom2, ecx 	;lowerBound = twoY - (height / 2)
	mov eax, (DINOGAMEBITMAP PTR [edx]).dwHeight
	add bottom2, eax  	;lowerBound = oneY + (height / 2)

;; Check if:
; A rect's bottom edge is higher than the other rect's top edge
; or
; A rect's right edge is further left than the other rect's left edge

	mov eax, bottom1
	mov ecx, top2 			; higher values = lower y
	cmp eax, ecx    		; If (one.bottom) < (two.top)
	jl dont_intersect 		; Then (one.bottom) is above (two.top) = no intersection

	mov eax, bottom2
	mov ecx, top1
	cmp eax, ecx  			; If (two.bottom) < (one.top)
	jl dont_intersect 		; Then (two.bottom) is above (one.top) = no intersection

	mov eax, right1
	mov ecx, left2
	cmp eax, ecx    		; If (one.right) < (two.left)
	jl dont_intersect 		; Then (one.right) is more left (two.left) = no intersection

	mov eax, right2
	mov ecx, left1
	cmp eax, ecx    		; If (two.right) < (one.left)
	jl dont_intersect 		; Then (two.right) is more left (one.left) = no intersection

intersect:
	mov eax, 1
	jmp the_end

dont_intersect:
	mov eax, 0

the_end:
	ret
CheckIntersect ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; GAME INITIALIZATION BUSINESS ;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; generating random integers in a range [lowerBound, higherBound]
randInt PROC lowerBound: DWORD, higherBound: DWORD
	;; range of [0, higherBound- lowerBound), you use ​nrandom​:
	mov eax, higherBound
	inc eax
	sub eax, lowerBound
	INVOKE nrandom, eax
	add eax, lowerBound ;; add lowerbound
	ret
randInt ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; MAKING SCREEN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
makeWhiteScreen PROC USES ebx edx
    mov ebx, 0       ;; zero out ebx
    mov edx, 0       ;; zero out ecx

    ;; Check if score is multiple of 500 to determine background color
    mov eax, score
    mov ecx, 1000     ; Check every 500 points
    mov edx, 0      ; clear edx for division
    div ecx         ; divide score by 500
    and eax, 1      ; check if quotient is odd or even
    jnz use_gray
    mov eax, 255    ; Use white if even
    jmp draw_background
use_gray:
    mov eax, 110   ; Use gray (110) if odd

draw_background:
    mov ecx, eax    ; Store color in ecx for drawing loop

draw_loop:
    INVOKE DrawPixel, ebx, edx, ecx
    inc edx
    cmp edx, 480
    jl draw_loop
    mov edx, 0      ; reset y
    inc ebx         ; next x
    cmp ebx, 640
    jl draw_loop

the_end:
    ret
makeWhiteScreen ENDP

drawMovingGround PROC USES ebx ecx
	INVOKE BasicBlit, OFFSET ground, ground0x, 327
	INVOKE BasicBlit, OFFSET ground, ground1x, 327
	INVOKE BasicBlit, OFFSET ground, ground0x, 227
	INVOKE BasicBlit, OFFSET ground, ground1x, 227
	INVOKE BasicBlit, OFFSET ground, ground0x, 427
	INVOKE BasicBlit, OFFSET ground, ground1x, 427
	;; the ground starts at 519
	;; only move ground if game is not over
	cmp isOver, 1
	je the_end
	;; hold onto cactus speed
	mov ebx, cactus_speed
;check_ground_0:
	cmp ground0x, -519
	jge move_ground0
;reset_ground_0:
	mov ecx, ground1x
	add ecx, 1038
	sub ecx, cactus_speed
	mov ground0x, ecx 
	jmp check_ground_1
move_ground0:
	sub ground0x, ebx
check_ground_1:
	cmp ground1x, -519
	jge move_ground1
;reset_ground_0:
	mov ecx, ground0x
	add ecx, 1038
	sub ecx, cactus_speed
	mov ground1x, ecx 
	jmp the_end

move_ground1:
	sub ground1x, ebx

the_end:
	ret
drawMovingGround ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DRAW THE INSTRUCTIONS SCREEN
makeScreen0 PROC
	INVOKE DrawStr, OFFSET instruct0, 270, 15, 0
	INVOKE DrawStr, OFFSET instruct1, 15, 35, 0
	INVOKE DrawStr, OFFSET instruct2, 15, 45, 0
	INVOKE DrawStr, OFFSET instruct3, 15, 55, 0
	INVOKE DrawStr, OFFSET instruct4, 15, 65, 0
	INVOKE DrawStr, OFFSET instruct5, 15, 75, 0
	INVOKE BasicBlitDino, OFFSET dino0, obj1x, obj1y_run
	INVOKE BasicBlit, OFFSET ground, 519, 327
	INVOKE BasicBlit, OFFSET whitebox, screen2box, 327
	ret
makeScreen0 ENDP

generateBirdStartPos PROC
	INVOKE randInt, 2700, 4000
	ret
generateBirdStartPos ENDP

;; generate a start position based on a reference point
generateCactusStartPos PROC USES ebx ecx refx: DWORD
	cmp refx, 670	;; see if the reference point is off screen
	jge use_ref		;; we want the reference point to be off the screen
	mov ebx, 820
	mov ecx, 1000
	jmp generate_random
	use_ref:
	mov ebx, refx
	mov ecx, refx
	add ebx, 150
	add ecx, 300
	generate_random:
	INVOKE randInt, ebx, ecx
	ret
generateCactusStartPos ENDP

;; generate a start position based on a reference point
generateCactusStartPos2 PROC USES ebx ecx refx: DWORD
    LOCAL min_distance: DWORD
    mov min_distance, 400    ; Minimum distance between cacti

    mov ebx, refx
    mov ecx, refx
    sub ebx, 170            ; lower bound
    add ecx, 170            ; upper bound

generate_random:
    INVOKE randInt, 670, 1710

    ; Check if too close to reference cactus
    mov ebx, refx
    sub ebx, eax            ; Get absolute distance
    jns check_distance      ; If positive, continue
    neg ebx                 ; Make negative distance positive

check_distance:
    cmp ebx, min_distance   ; Compare with minimum allowed distance
    jl generate_random      ; If too close, generate new position

    ; Additional boundary checks
    mov ebx, refx
    sub ebx, 170            ; lower bound
    mov ecx, refx
    add ecx, 170            ; upper bound

    cmp eax, ebx           ; check lower bound
    jle the_end
    cmp eax, ecx           ; check upper bound
    jge the_end
    jmp generate_random     ; If within forbidden zone, try again

the_end:
    ret
generateCactusStartPos2 ENDP

generateCloudStartPosY PROC
	INVOKE randInt, 35, 255
	ret
generateCloudStartPosY ENDP

drawClouds PROC USES ebx eax
	mov ebx, cloud_speed
	;; can also generate new height

move_cloud1:
	cmp cloud1x, -30
	jle cloud1_moved_offscreen						;; bird is offscreen so we don't want to draw anymore

	sub cloud1x, ebx
	cmp cloud1x, 670
	jge move_cloud2			;; don't draw if still moving onto screen

draw_cloud1:
	INVOKE BasicBlit, OFFSET cloud, cloud1x, cloud1y
	jmp move_cloud2

cloud1_moved_offscreen:
	INVOKE generateCloudStartPosY			;; randomly generate start position
	mov cloud1y, eax
	mov cloud1x, 670 ;;reset cloud x pos

move_cloud2:
	cmp cloud2x, -30
	jle cloud2_moved_offscreen						;; bird is offscreen so we don't want to draw anymore

	sub cloud2x, ebx
	cmp cloud2x, 670
	jge move_cloud3			;; don't draw if still moving onto screen

draw_cloud2:
	INVOKE BasicBlit, OFFSET cloud, cloud2x, cloud2y
	jmp move_cloud3

cloud2_moved_offscreen:
	INVOKE generateCloudStartPosY			;; randomly generate start position
	mov cloud2y, eax
	mov cloud2x, 670 ;;reset cloud x pos

move_cloud3:
	cmp cloud3x, -30
	jle cloud3_moved_offscreen						;; bird is offscreen so we don't want to draw anymore

	sub cloud3x, ebx
	cmp cloud3x, 670
	jge the_end		;; don't draw if still moving onto screen

draw_cloud3:
	INVOKE BasicBlit, OFFSET cloud, cloud3x, cloud3y
	jmp the_end

cloud3_moved_offscreen:
	INVOKE generateCloudStartPosY			;; randomly generate start position
	mov cloud3y, eax
	mov cloud3x, 670 ;;reset cloud x pos

the_end:
	ret
drawClouds ENDP

makeScreen2 PROC USES eax ebx
	LOCAL obj1ptr: PTR DINOGAMEBITMAP, obj1y: DWORD
	LOCAL obj2ptr: PTR DINOGAMEBITMAP, obj2y: DWORD
	LOCAL obj3ptr: PTR DINOGAMEBITMAP, obj3y: DWORD
	LOCAL obj4ptr: PTR DINOGAMEBITMAP, obj4y: DWORD

;; DRAWING THE BIRD

	cmp obj2_disabled, 1
	je obj3_0 ;;dont_make_bird
	cmp obj2, 0
	jne obj2_1
	inc obj2
	mov obj2ptr, OFFSET bird0		;; using bird0
	jmp get_obj2_height

obj2_1:
	mov obj2ptr, OFFSET bird1		;; using bird1
	dec obj2

get_obj2_height:							;; use randomly generated height
	cmp obj2_mode, 0
	jne obj2_med_mode

	mov ebx, obj2y_high
	jmp set_obj2_height
	obj2_med_mode:
	cmp obj2_mode, 1
	jne obj2_low_mode

	mov ebx, obj2y_mid
	jmp set_obj2_height
	obj2_low_mode:
	mov ebx, obj2y_low

set_obj2_height:
	mov obj2y, ebx

move_bird:
	cmp obj2x, -30
	jle bird_moved_offscreen				;; bird has moved offscreen so we don't want to draw anymore

	mov ebx, obj2_speed
	sub obj2x, ebx					;; move bird across the screen
	cmp obj2x, 670
	jge obj3_0			;; don't draw if still moving onto screen

draw_bird:
	INVOKE BasicBlit, obj2ptr, obj2x, obj2y	;; drawing the object
	jmp obj3_0

bird_moved_offscreen:
	INVOKE randInt, 0, 2
	mov obj2_mode, eax
	INVOKE generateBirdStartPos			;; randomly generate start position
	mov obj2x, eax

obj3_0:
;; DRAWING THE CACTUS1
	cmp obj3_mode, 0
	jne obj3_cactus_1
	obj3_cactus_0:
	mov obj3ptr, OFFSET cactus0		;; using cactus0
	mov ebx, 300
	jmp set_obj3
	obj3_cactus_1:
	cmp obj3_mode, 1
	jne obj3_cactus_2
	mov obj3ptr, OFFSET cactus1		;; using cactus1
	mov ebx, 310
	jmp set_obj3
	obj3_cactus_2:
	mov obj3ptr, OFFSET cactus2		;; using cactus2
	mov ebx, 310					;; add random height later

set_obj3:
	mov obj3y, ebx

obj4_0:
;; DRAWING THE CACTUS1
	cmp obj4_mode, 0
	jne obj4_cactus_1
	obj4_cactus_0:
	mov obj4ptr, OFFSET cactus0		;; using cactus0
	mov ebx, 300
	jmp set_obj4
	obj4_cactus_1:
	cmp obj4_mode, 1
	jne obj4_cactus_2
	mov obj4ptr, OFFSET cactus1		;; using cactus1
	mov ebx, 310
	jmp set_obj4
	obj4_cactus_2:
	mov obj4ptr, OFFSET cactus2		;; using cactus2
	mov ebx, 310					;; add random height later

set_obj4:
	mov obj4y, ebx

;; Check for lane switching
check_lane_switch:
    ; Check if cooldown is active
    cmp lane_switch_cooldown, 0
    jg do_cooldown              ; If cooldown > 0, skip lane switching

    cmp KeyPress, 'W'           ; Check W key for moving up
    je do_switch_up
    cmp KeyPress, 'S'           ; Check S key for moving down
    je do_switch_down
    jmp key0                    ; No lane switch, continue with normal controls

do_cooldown:
    dec lane_switch_cooldown    ; Decrease cooldown counter
    jmp key0                    ; Skip lane switching this frame

do_switch_up:
    mov lane_switch_cooldown, 2 ; Set cooldown
    jmp switch_lane_up          ; Proceed with normal up switch

do_switch_down:
    mov lane_switch_cooldown, 2 ; Set cooldown
    jmp switch_lane_down        ; Proceed with normal down switch

switch_lane_up:
    cmp current_lane, 0         ; Already in top lane?
    je key0                     ; If yes, ignore
    dec current_lane            ; Move up one lane

    ; Set Y positions based on current_lane value
    cmp current_lane, 0
    je set_top_lane
    jmp set_middle_lane        ; Must be middle lane if we get here

set_top_lane:
    mov obj1y_run, 200        ; Top lane Y position
    mov obj1y_duck, 218       ; Duck position = run + 18
    mov obj1y_jump, 200       ; Reset jump position
    mov obj1_going_down, 0    ; Reset jump state
    jmp key0

set_middle_lane:
    mov obj1y_run, 300        ; Middle lane Y position
    mov obj1y_duck, 318       ; Duck position = run + 18
    mov obj1y_jump, 300       ; Reset jump position
    mov obj1_going_down, 0    ; Reset jump state
    jmp key0

switch_lane_down:
    cmp current_lane, 2         ; Already in bottom lane?
    je key0                     ; If yes, ignore
    inc current_lane            ; Move down one lane

    ; Set Y positions based on current_lane value
    cmp current_lane, 2
    je set_bottom_lane
    jmp set_middle_lane        ; Must be middle lane if we get here

set_bottom_lane:
    mov obj1y_run, 400        ; Bottom lane Y position
    mov obj1y_duck, 418       ; Duck position = run + 18
    mov obj1y_jump, 400       ; Reset jump position
    mov obj1_going_down, 0    ; Reset jump state
    jmp key0

;; DRAWING THE DINO
key0:
	mov ebx, obj1y_jump
	cmp obj1y_run, ebx				;; check if running height is the same
	jne jump 						;; if not the same we are in the middle of jumping	
	cmp KeyPress, VK_SPACE					;; checking SPACE for jump
	je play_jump_sound
	cmp KeyPress, VK_UP						;; checking UP arrow
	jne key1 								;; check the next button
	play_jump_sound:
	invoke PlaySound, offset jump_sound, 0, SND_FILENAME OR SND_ASYNC
	jump:
	mov obj1ptr, OFFSET dino0				;; using dino 0
	cmp obj1y_jump, 180			;; max height is 175
	jne direction_check							;; go from going up to going down
	;; otherwise we need to set the direction flag
	inc obj1_going_down

direction_check:
    cmp obj1_going_down, 1
    jne go_up
    jmp go_down          ; Make sure we go down if flag is set

go_down:
    ; Check if down key is pressed for fast fall
    cmp KeyPress, VK_DOWN
    jne normal_fall

    ; Get current lane's ground position
    mov eax, current_lane
    mov ebx, 4
    mul ebx
    mov ebx, OFFSET lane_ground
    add ebx, eax
    mov eax, obj1y_jump
    add eax, 45          ; Fast fall speed
    cmp eax, [ebx]      ; Compare with current lane's ground
    jge ground_hit      
    mov obj1y_jump, eax
    jmp set_jump_height

normal_fall:
    mov eax, current_lane
    mov ebx, 4
    mul ebx
    mov ebx, OFFSET lane_ground
    add ebx, eax
    mov eax, obj1y_jump
    add eax, 30          ; Normal fall speed
    cmp eax, [ebx]      ; Compare with current lane's ground
    jge ground_hit
    mov obj1y_jump, eax
    jmp set_jump_height

ground_hit:
    mov eax, current_lane
    mov ebx, 4
    mul ebx
    mov ebx, OFFSET lane_ground
    add ebx, eax
    mov eax, [ebx]      ; Get current lane's ground position
    mov obj1y_jump, eax
    mov obj1_going_down, 0
    jmp set_jump_height

go_up:
    cmp KeyPress, VK_DOWN
    je cancel_jump

    ; Calculate max height relative to current lane
    mov eax, current_lane
    mov ebx, 4
    mul ebx
    mov ebx, OFFSET lane_ceiling
    add ebx, eax
    mov eax, obj1y_jump
    sub eax, 30         ; Going up
    cmp eax, [ebx]     ; Compare with current lane's ceiling
    jle reached_max
    mov obj1y_jump, eax
    jmp set_jump_height

reached_max:
    ; Set max height relative to current lane
    mov eax, current_lane
    mov ebx, 4
    mul ebx
    mov ebx, OFFSET lane_ceiling
    add ebx, eax
    mov eax, [ebx]     ; Get current lane's ceiling height
    mov obj1y_jump, eax
    mov obj1_going_down, 1    ; Start falling immediately
    jmp go_down            ; Start falling right away instead of waiting

cancel_jump:
    mov obj1_going_down, 1     ; Force transition to falling
    mov eax, obj1y_jump        ; Get current position
    add eax, 45               ; Add fast fall speed
    cmp eax, 300             ; Check if would hit ground
    jge ground_hit           ; If at/below ground, snap to ground
    mov obj1y_jump, eax      ; Otherwise apply fast fall
    jmp set_jump_height

set_jump_height:
	mov ebx, obj1y_jump;; doing something here						;; setting jump height
	mov obj1y, ebx
	jmp move_cactus1

key1:	;; DOWN KEY
	cmp KeyPress, VK_DOWN					;; checking DOWN ARROW for duck
	jne noKey 								;; check the next button
	mov ebx, obj1y_duck					;; setting jump height
	mov obj1y, ebx

	cmp obj1_duck, 0
	jne obj1_duck_1
	inc obj1_duck
	mov obj1ptr, OFFSET dino3		;; using dino 3
	jmp move_cactus1
	obj1_duck_1:
	mov obj1ptr, OFFSET dino4		;; using dino 4
	dec obj1_duck
	jmp move_cactus1

noKey:				;; default move, no keys are being pressed
	mov ebx, obj1y_run					;; setting jump height
	mov obj1y, ebx

	cmp obj1_run, 0
	jne obj1_run_1
	mov obj1ptr, OFFSET dino0		;; using dino 0
	inc obj1_run						;; use dino 1 next
	jmp move_cactus1
	obj1_run_1:	
	cmp obj1_run, 1
	jne obj1_run_2
	mov obj1ptr, OFFSET dino1		;; using dino 1
	inc obj1_run						;; use dino 2 next
	jmp move_cactus1
	obj1_run_2:	
	mov obj1ptr, OFFSET dino2		;; using dino 2
	mov obj1_run, 0						;; use dino 0 next

move_cactus1:
	cmp obj3x, -30
	jle cactus1_moved_offscreen						;; bird is offscreen so we don't want to draw anymore

	mov ebx, cactus_speed
	sub obj3x, ebx
	cmp obj3x, 670
	jge move_cactus2			;; don't draw if still moving onto screen

draw_cactus1:
	INVOKE BasicBlit, obj3ptr, obj3x, obj3y
	jmp move_cactus2

cactus1_moved_offscreen:
	INVOKE randInt, 0, 2
	mov obj3_mode, eax
	INVOKE generateCactusStartPos2, obj4x			;; randomly generate start position
	mov obj3x, eax

move_cactus2:
	cmp obj4x, -30
	jle cactus2_moved_offscreen						;; bird is offscreen so we don't want to draw anymore

	mov ebx, cactus_speed
	sub obj4x, ebx
	cmp obj4x, 670
	jge draw_top_lane

draw_cactus2:
	INVOKE BasicBlit, obj4ptr, obj4x, obj4y
	jmp draw_top_lane

cactus2_moved_offscreen:
	INVOKE randInt, 0, 2
	mov obj4_mode, eax
	;; randomly generate start position
	INVOKE generateCactusStartPos2, obj3x
	mov obj4x, eax

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NEW MECHANIC: DRAW TOP AND BOTTOM LANES
;; DRAWING THE TOP AND BOTTOM LANE OBSTACLES
;; Draw top lane obstacles
draw_top_lane:
    cmp top_obj_mode, 0
    je draw_top_cactus
    
    ;; Draw bird in top lane
    INVOKE BasicBlit, obj2ptr, top_bird_x, top_lane_y
    mov ebx, obj2_speed
    sub top_bird_x, ebx
    cmp top_bird_x, -30
    jle reset_top_bird
    jmp draw_bottom_lane

reset_top_bird:
    INVOKE generateBirdStartPos
    mov top_bird_x, eax
    jmp draw_bottom_lane
    
draw_top_cactus:
    INVOKE BasicBlit, obj3ptr, top_cactus_x, top_lane_y
    mov ebx, cactus_speed
    sub top_cactus_x, ebx
    cmp top_cactus_x, -30
    jle reset_top_cactus
    jmp draw_bottom_lane

reset_top_cactus:
    INVOKE randInt, 0, 2
    mov top_obj_mode, eax
    INVOKE generateCactusStartPos2, bottom_cactus_x
    mov top_cactus_x, eax

;; Draw bottom lane obstacles
draw_bottom_lane:
    cmp bottom_obj_mode, 0
    je draw_bottom_cactus
    
    ;; Draw bird in bottom lane
    INVOKE BasicBlit, obj2ptr, bottom_bird_x, bottom_lane_y
    mov ebx, obj2_speed
    sub bottom_bird_x, ebx
    cmp bottom_bird_x, -30
    jle reset_bottom_bird
    jmp draw_dino

reset_bottom_bird:
    INVOKE generateBirdStartPos
    mov bottom_bird_x, eax
    jmp draw_dino
    
draw_bottom_cactus:
    INVOKE BasicBlit, obj4ptr, bottom_cactus_x, bottom_lane_y
    mov ebx, cactus_speed
    sub bottom_cactus_x, ebx
    cmp bottom_cactus_x, -30
    jle reset_bottom_cactus
    jmp draw_dino

reset_bottom_cactus:
    INVOKE randInt, 0, 2
    mov bottom_obj_mode, eax
    INVOKE generateCactusStartPos2, top_cactus_x
    mov bottom_cactus_x, eax
;; END OF NEW MECHANIC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

draw_dino:
	INVOKE drawClouds
	INVOKE BasicBlitDino, obj1ptr, obj1x, obj1y		;; drawing the object
	mov isOver, eax
	cmp eax, 1;; see if game isover
	jne the_end
	;; redraw everything with dead dino
	INVOKE makeWhiteScreen
	cmp obj2_disabled, 1
	je continue_redraw
	INVOKE BasicBlit, obj2ptr, obj2x, obj2y

continue_redraw:
    INVOKE BasicBlit, obj3ptr, obj3x, obj3y      ; Main lane cactus
    INVOKE BasicBlit, obj4ptr, obj4x, obj4y      ; Main lane cactus 2

    ; Draw top lane obstacles
    cmp top_obj_mode, 0
    je redraw_top_cactus
    INVOKE BasicBlit, obj2ptr, top_bird_x, top_lane_y    ; Top lane bird
    jmp redraw_bottom

redraw_top_cactus:
    INVOKE BasicBlit, obj3ptr, top_cactus_x, top_lane_y  ; Top lane cactus

redraw_bottom:
    ; Draw bottom lane obstacles
    cmp bottom_obj_mode, 0
    je redraw_bottom_cactus
    INVOKE BasicBlit, obj2ptr, bottom_bird_x, bottom_lane_y  ; Bottom lane bird
    jmp draw_dead_dino

redraw_bottom_cactus:
    INVOKE BasicBlit, obj4ptr, bottom_cactus_x, bottom_lane_y  ; Bottom lane cactus

draw_dead_dino:
    ;; DRAWING THE BACKGROUND
    INVOKE drawClouds
    INVOKE BasicBlitDino, OFFSET dino5, obj1x, obj1y
    invoke PlaySound, offset dead_sound, 0, SND_FILENAME OR SND_ASYNC

the_end:
;; DETERMINE IF pterodactyls have been enabled or not
	cmp obj2_disabled, 1
	jne write_enabled
	mov ebx, OFFSET birdStr1
	jmp print_scoreboard
	write_enabled:
	mov ebx, OFFSET birdStr0

print_scoreboard:
    INVOKE DrawStr, ebx, 5, 5, 0 ;; print if bird is disabled or not

    ;; Check if score is multiple of 1000
    mov eax, score
    mov ebx, 1000
    mov edx, 0
    div ebx
    cmp edx, 0         ; check if remainder is 0
    jne normal_score   ; if not divisible by 1000, print normally
    cmp eax, 0         ; check if quotient is 0 (score = 0)
    je normal_score    ; if score is 0, print normally

normal_score:
    INVOKE PrintScore

skip_score_print:
    ;; Continue with rest of the code...
    ;; Only increment score if game is not paused and pterodactyls are enabled
    cmp isPaused, 1
    je check_level_up

    cmp obj2_disabled, 1    ; Check if pterodactyls are disabled
    je check_level_up       ; Changed from check_high_score

    inc score               ; Only increment if pterodactyls are enabled

check_level_up:            ; New section for level up sound
    mov eax, score
    mov ebx, 100
    mov edx, 0          ; clear edx for division
    div ebx             ; divide score by 100
    cmp edx, 0         ; check if remainder is 0
    jne check_high_score    ; if not divisible by 100, skip sound
    cmp eax, 0         ; check if quotient is 0 (score = 0)
    je check_high_score     ; if score is 0, skip sound
    invoke PlaySound, offset level_up_sound, 0, SND_FILENAME OR SND_ASYNC

check_high_score:
    cmp highScore, 0
    je the_end_end
    INVOKE PrintHighScore

the_end_end:

	ret
makeScreen2 ENDP

GameInit PROC USES eax
;; background music
	; INVOKE PlaySound, offset SndPath, 0, SND_FILENAME OR SND_ASYNC OR SND_LOOP ; Disabled Music
;; for random number generation:
	rdtsc
	INVOKE nseed, eax
	INVOKE makeWhiteScreen	
	INVOKE makeScreen0			;; draw instructions screen 
	;; initiation of cloud heights
	INVOKE generateCloudStartPosY
	mov cloud1y, eax
	INVOKE generateCloudStartPosY
	mov cloud2y, eax
	INVOKE generateCloudStartPosY
	mov cloud3y, eax
	ret         ;; Do not delete this line!!!
GameInit ENDP

GameRestart PROC USES eax ebx
	mov screenNum, 2
	;;INVOKE generateStartPos			;; randomly generate start position
	;;mov obj2x, eax	
	mov obj2x, 1970
	;;INVOKE generateStartPos			;; randomly generate start position
	mov obj3x, 890
	;;mov obj3x, eax		
	mov obj4x, 1300	

	;; Initialize top lane
    mov top_cactus_x, 890
    mov top_bird_x, 1870
    mov top_obj_mode, 0

    ;; Initialize bottom lane
    mov bottom_cactus_x, 1300
    mov bottom_bird_x, 2100
    mov bottom_obj_mode, 0

	;; reset cloud positions
	mov cloud1x, 670
	mov cloud2x, 883
	mov cloud3x, 1096

	dec isOver	;; set isOver back to 0
	mov ebx, score
	cmp highScore, ebx					;; new high score???
	jge clear_score
	mov highScore, ebx
	clear_score:
	mov score, 0						;; score back to 0
	ret         ;; Do not delete this line!!!
GameRestart ENDP

GamePlay PROC 
	cmp isOver, 1			;; check if game is over
	jne screen0             ;; if not over continue
	cmp KeyPress, VK_SPACE	;; if the game is over check if we are restarting

	jne screen2 			;; if we are not restarting
	INVOKE GameRestart
screen0:
	cmp screenNum, 0
	jne screen1					;; if not screen 0, check if it's the next screen

	cmp KeyPress, VK_SPACE		;; check if space was pressed
	jne the_end

	inc screenNum 				;; if space was pressed we increment to next screen
	jmp the_end					;; and go to the end

screen1:
	;; make a slidey box that shifts off the screen
	cmp screenNum, 1
	jne screen2	
	INVOKE makeWhiteScreen
	INVOKE BasicBlitDino, OFFSET dino0, obj1x, obj1y_run
	INVOKE BasicBlit, OFFSET ground, 519, 327
	INVOKE BasicBlit, OFFSET whitebox, screen2box, 327

	cmp screen2box, 950
	jge next_screen
	add screen2box, 40
	jmp the_end
next_screen:
	inc screenNum

screen2:
	cmp isOver, 1   					;; END GAME
	je screen3

	cmp KeyPress, VK_RIGHT					;; checking DOWN ARROW for duck
	je P_check							;; see if we need to toggle pause
	cmp isPaused, 0						;; see if game is currently paused
	jne the_end
	jmp not_paused

P_check:
	cmp isPaused, 0						;; if not paused we want to pause
	jne unpause							;; game is paused, we want to unpause

	inc isPaused
	INVOKE DrawStr, OFFSET pausedStr, 235, 215, 0
	jmp the_end

unpause:
	dec isPaused

not_paused:
	cmp KeyPress, VK_LEFT
	jne continue_screen_2
	mov obj2x, 1170			; reset obj2x
	cmp obj2_disabled, 1
	jne obj2_was_enabled		; obj2_disabled = 0
	dec obj2_disabled
	jmp continue_screen_2

obj2_was_enabled:
	inc obj2_disabled

continue_screen_2:
	INVOKE makeWhiteScreen		;; clears the screen so we can nicely draw everything again

	cmp screenNum, 2
	jne screen3			;; if not screen 1, check if it's the next screen

	INVOKE makeScreen2			;; draw game screen 
	INVOKE drawMovingGround
	jmp the_end

screen3:		;; end game string
	INVOKE DrawStr, OFFSET endStr, 245, 205, 0	;;end game
	INVOKE DrawStr, OFFSET restartStr, 190, 225, 0		;; restart string

the_end:

	ret         ;; Do not delete this line!!!
GamePlay ENDP

END
