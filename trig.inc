; #########################################################################
;
;   trig.inc
;
; #########################################################################

FXPT TYPEDEF SDWORD

EXTERNDEF SINTAB:WORD

FixedSin PROTO STDCALL angle:FXPT
FixedCos PROTO STDCALL angle:FXPT