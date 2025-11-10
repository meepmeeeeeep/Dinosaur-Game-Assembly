; #########################################################################
;
;   game.inc
;
; #########################################################################

;; Library Definitions
MouseInfo STRUCT
 horiz DWORD ?
 vert  DWORD ?
 buttons DWORD ?
MouseInfo ENDS

MK_CONTROL  = 0008h  ;; The CTRL key is down.
MK_LBUTTON  = 0001h  ;; The left mouse button is down.
MK_MBUTTON  = 0010h  ;; The middle mouse button is down.
MK_RBUTTON  = 0002h  ;; The right mouse button is down.
MK_SHIFT    = 0004h  ;; The SHIFT key is down.
MK_XBUTTON1 = 0020h  ;; The first X button is down.
MK_XBUTTON2 = 0040h  ;; The second X button is down.

;; Library Functions
BlackStarField	PROTO
DrawStr PROTO myStr:PTR BYTE, x:DWORD, y:DWORD, color:DWORD

;; Library Data
EXTERNDEF StarBitmap:DINOGAMEBITMAP
EXTERNDEF MouseStatus:MouseInfo
EXTERNDEF KeyUp:DWORD
EXTERNDEF KeyDown:DWORD
EXTERNDEF KeyPress:DWORD
;; added bitmaps
EXTERNDEF dino0:DINOGAMEBITMAP
EXTERNDEF dino1:DINOGAMEBITMAP
EXTERNDEF dino2:DINOGAMEBITMAP
EXTERNDEF dino3:DINOGAMEBITMAP
EXTERNDEF dino4:DINOGAMEBITMAP
EXTERNDEF dino5:DINOGAMEBITMAP
EXTERNDEF bird0:DINOGAMEBITMAP
EXTERNDEF bird1:DINOGAMEBITMAP
EXTERNDEF cactus0:DINOGAMEBITMAP
EXTERNDEF cactus1:DINOGAMEBITMAP
EXTERNDEF cactus2:DINOGAMEBITMAP
EXTERNDEF cloud:DINOGAMEBITMAP
EXTERNDEF ground:DINOGAMEBITMAP
EXTERNDEF whitebox:DINOGAMEBITMAP
;; User Defined Functions
GameInit PROTO
GamePlay PROTO
CheckIntersect PROTO oneX:DWORD, oneY:DWORD, oneBitmap:PTR DINOGAMEBITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR DINOGAMEBITMAP 




