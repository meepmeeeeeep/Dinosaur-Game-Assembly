@echo off
REM ========================================================================
REM  DINOSAUR GAME - BUILD SCRIPT
REM ========================================================================
REM  This batch file compiles and links all Assembly source files to create
REM  the executable game file.
REM
REM  WHAT THIS SCRIPT DOES:
REM  1. Sets paths to MASM32 tools (assembler and linker)
REM  2. Sets paths to required libraries and include files
REM  3. Assembles each .asm file into .obj (object) files
REM  4. Links all .obj files together into final .exe
REM
REM  HOW TO USE:
REM  - Double-click this file, OR
REM  - Run from command prompt: make.bat
REM
REM  REQUIREMENTS:
REM  - MASM32 SDK installed (typically in C:\masm32)
REM  - All .asm source files in same directory
REM ========================================================================

:::::::::::::::::::::::::::::::::::::::::::::::
:::                                         :::
::: STEP 1: CONFIGURE YOUR PATHS            :::
::: (Modify these paths for your system)    :::
:::                                         :::
:::::::::::::::::::::::::::::::::::::::::::::::

REM ---------------------------------------------------------------------
REM MASMPATH: Location of ml.exe (assembler) and link.exe (linker)
REM ---------------------------------------------------------------------
REM Default Windows location: C:\masm32\bin
REM
REM TO FIND YOUR PATH:
REM 1. Open Command Prompt
REM 2. Navigate to your masm32\bin folder
REM 3. Type: echo %cd%
REM 4. Copy that path here
REM
REM For Wine on Mac/Linux:
REM - Run: wine cmd.exe
REM - Navigate to masm32\bin (might be in ~/.wine/drive_c/masm32/bin)
REM - Type: echo %cd%
REM ---------------------------------------------------------------------
set MASMPATH=C:\masm32\bin

REM ---------------------------------------------------------------------
REM MASMLIBPATH: Location of library files (.lib)
REM ---------------------------------------------------------------------
REM Libraries needed: user32.lib, kernel32.lib, gdi32.lib, masm32.lib
REM Default location: C:\masm32\lib
REM
REM These libraries provide Windows API functions for:
REM - user32.lib:   Window management, user input
REM - kernel32.lib: Core system functions, memory management
REM - gdi32.lib:    Graphics drawing functions
REM - masm32.lib:   MASM32-specific utilities
REM ---------------------------------------------------------------------
set MASMLIBPATH=C:\masm32\lib

REM ---------------------------------------------------------------------
REM MASMINCPATH: Location of include files (.inc)
REM ---------------------------------------------------------------------
REM Includes needed: windows.inc, user32.inc, winmm.inc
REM Default location: C:\masm32\include
REM
REM These files contain:
REM - Function prototypes for Windows APIs
REM - Constant definitions (like VK_SPACE, VK_UP, etc.)
REM - Structure definitions used by Windows
REM ---------------------------------------------------------------------
set MASMINCPATH=C:\masm32\include

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::
::: STEP 2: BUILD PROCESS (DO NOT MODIFY BELOW)
:::
::: The script will now:
::: 1. Add MASM tools to system PATH
::: 2. Assemble each .asm file into .obj file
::: 3. Link all .obj files into final executable
:::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

REM ---------------------------------------------------------------------
REM Add MASM binaries to PATH so we can run ml.exe and link.exe
REM ---------------------------------------------------------------------
set path=%path%;%MASMPATH%

REM =====================================================================
REM COMPILATION PHASE: Assemble .asm files into .obj (object) files
REM =====================================================================
REM
REM ML.EXE (Macro Assembler) OPTIONS EXPLAINED:
REM /I%MASMINCPATH%  - Include path for .inc files
REM /c               - Compile only, don't link yet
REM /coff            - Common Object File Format (32-bit Windows)
REM /Cp              - Preserve case of user identifiers
REM
REM WHAT IS AN OBJECT FILE (.obj)?
REM - Intermediate compiled code
REM - Contains machine code but not yet executable
REM - Multiple .obj files linked together to make .exe
REM =====================================================================

echo.
echo ========================================
echo  COMPILING SOURCE FILES
echo ========================================
echo.

REM ---------------------------------------------------------------------
REM Compile stars.asm - Star field rendering functions
REM ---------------------------------------------------------------------
echo [1/6] Assembling: stars.asm
ml /I%MASMINCPATH% /c /coff /Cp stars.asm

REM Check if compilation succeeded (errorlevel 0 = success)
if %errorlevel% neq 0 goto :error

REM ---------------------------------------------------------------------
REM Compile lines.asm - Line drawing functions
REM ---------------------------------------------------------------------
echo [2/6] Assembling: lines.asm
ml /I%MASMINCPATH% /c /coff /Cp lines.asm

if %errorlevel% neq 0 goto :error

REM ---------------------------------------------------------------------
REM Compile trig.asm - Trigonometry functions
REM ---------------------------------------------------------------------
echo [3/6] Assembling: trig.asm
ml /I%MASMINCPATH% /c /coff /Cp trig.asm

if %errorlevel% neq 0 goto :error

REM ---------------------------------------------------------------------
REM Compile blit.asm - Bitmap blitting and drawing functions
REM ---------------------------------------------------------------------
echo [4/6] Assembling: blit.asm
ml /I%MASMINCPATH% /c /coff /Cp blit.asm

if %errorlevel% neq 0 goto :error

REM ---------------------------------------------------------------------
REM Compile game.asm - Main game logic and entry point
REM ---------------------------------------------------------------------
echo [5/6] Assembling: game.asm
ml /I%MASMINCPATH% /c /coff /Cp game.asm

if %errorlevel% neq 0 goto :error

REM ---------------------------------------------------------------------
REM Compile bitmaps.asm - Sprite and bitmap data
REM ---------------------------------------------------------------------
echo [6/6] Assembling: bitmaps.asm
ml /I%MASMINCPATH% /c /coff /Cp bitmaps.asm

if %errorlevel% neq 0 goto :error

REM =====================================================================
REM LINKING PHASE: Combine all .obj files into executable
REM =====================================================================
REM
REM LINK.EXE OPTIONS EXPLAINED:
REM /SUBSYSTEM:WINDOWS  - Create Windows GUI application (not console)
REM /LIBPATH:%MASMLIBPATH% - Where to find .lib library files
REM
REM FILES BEING LINKED:
REM - game.obj:    Main game logic
REM - blit.obj:    Drawing functions
REM - trig.obj:    Math functions
REM - lines.obj:   Line rendering
REM - stars.obj:   Background effects
REM - bitmaps.obj: Sprite data
REM - libgame.obj: Pre-compiled game library (provided)
REM
REM OUTPUT:
REM - game.exe: Final executable file
REM =====================================================================

echo.
echo ========================================
echo  LINKING OBJECT FILES
echo ========================================
echo.

link /SUBSYSTEM:WINDOWS /LIBPATH:%MASMLIBPATH% game.obj blit.obj trig.obj lines.obj stars.obj bitmaps.obj libgame.obj 

REM Check if linking succeeded
if %errorlevel% neq 0 goto :error

REM =====================================================================
REM BUILD SUCCESSFUL!
REM =====================================================================
echo.
echo ========================================
echo  BUILD COMPLETED SUCCESSFULLY!
echo ========================================
echo.
echo Output file: game.exe
echo You can now run the game by double-clicking game.exe
echo.
pause
goto :EOF

REM =====================================================================
REM ERROR HANDLING
REM =====================================================================
REM If any step fails, execution jumps here
:error
echo.
echo ========================================
echo  BUILD FAILED!
echo ========================================
echo.
echo Error code: %errorlevel%
echo.
echo COMMON ISSUES:
echo 1. MASM32 not installed or paths incorrect
echo 2. Missing source files (.asm)
echo 3. Syntax errors in Assembly code
echo 4. Missing include files (.inc)
echo 5. Missing library files (.lib)
echo.
echo TROUBLESHOOTING:
echo - Verify MASM32 is installed in C:\masm32
echo - Check that all paths at top of this file are correct
echo - Ensure all .asm files are in current directory
echo - Review error messages above for specific file/line
echo.
pause
goto :EOF

REM =====================================================================
REM BATCH FILE SYNTAX REFERENCE
REM =====================================================================
REM
REM @echo off        - Don't show commands as they execute
REM echo            - Print text to screen
REM REM             - Comment (remark), ignored by batch processor
REM set VAR=value   - Create/set environment variable
REM %VAR%           - Use value of environment variable
REM if condition    - Conditional execution
REM goto :label     - Jump to labeled section
REM :label          - Define a label (jump target)
REM pause           - Wait for user to press any key
REM %errorlevel%    - Exit code of last program (0=success, other=error)
REM neq             - Not equal to (used with if)
REM
REM =====================================================================