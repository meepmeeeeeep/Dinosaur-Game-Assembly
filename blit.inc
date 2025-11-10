; #########################################################################
;
;   blit.inc
;
; #########################################################################


_DINOGAMEBITMAP STRUCT
 dwWidth      DWORD  ?
 dwHeight     DWORD  ?
 bTransparent BYTE   ?
              BYTE   3 DUP(?)
 lpBytes      DWORD  ?
_DINOGAMEBITMAP ENDS

DINOGAMEBITMAP TYPEDEF _DINOGAMEBITMAP

EXTERNDEF ScreenBitsPtr:DWORD
DrawDinoPixel PROTO STDCALL x:DWORD, y:DWORD, color:DWORD
BasicBlit PROTO STDCALL ptrBitmap:PTR DINOGAMEBITMAP, xcenter:DWORD, ycenter:DWORD
BasicBlitDino PROTO STDCALL ptrBitmap:PTR DINOGAMEBITMAP, xcenter:DWORD, ycenter:DWORD
RotateBlit PROTO STDCALL ptrBitmap:PTR DINOGAMEBITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT






