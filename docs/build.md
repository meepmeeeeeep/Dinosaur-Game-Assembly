# Build System Documentation

Complete guide to understanding and using the build system for the Dinosaur Game Assembly project.

## Table of Contents
- [Overview](#overview)
- [Build Process](#build-process)
- [Batch File Syntax](#batch-file-syntax)
- [MASM32 Tools](#masm32-tools)
- [Troubleshooting](#troubleshooting)
- [Advanced Topics](#advanced-topics)

---

## Overview

### What is a Build System?

A build system converts human-readable source code into executable programs. For Assembly language:

```
Source Code (.asm) → Assembler → Object Files (.obj) → Linker → Executable (.exe)
```

### Project Build Flow

```
make.bat (Build Script)
    ↓
┌─────────────────────────────────┐
│ COMPILATION PHASE               │
│ (Assembler: ml.exe)             │
├─────────────────────────────────┤
│ stars.asm    → stars.obj        │
│ lines.asm    → lines.obj        │
│ trig.asm     → trig.obj         │
│ blit.asm     → blit.obj         │
│ game.asm     → game.obj         │
│ bitmaps.asm  → bitmaps.obj      │
└─────────────────────────────────┘
    ↓
┌─────────────────────────────────┐
│ LINKING PHASE                   │
│ (Linker: link.exe)              │
├─────────────────────────────────┤
│ Combine all .obj files          │
│ Add Windows libraries           │
│ Resolve external references     │
│ Generate executable             │
└─────────────────────────────────┘
    ↓
game.exe (Final Executable)
```

---

## Build Process

### Phase 1: Compilation (Assembly)

Each `.asm` file is assembled into an `.obj` (object) file.

**Command Structure**:
```batch
ml /I%MASMINCPATH% /c /coff /Cp filename.asm
```

**What Happens**:
1. **Parse**: Read Assembly instructions
2. **Translate**: Convert to machine code
3. **Create**: Generate object file with:
   - Machine code
   - Symbol table (function/variable names)
   - Relocation information
   - External references

**Example**:
```assembly
; In game.asm
EXTERN DrawPixel:PROC    ; Reference to function in blit.asm

MyProc PROC
    call DrawPixel       ; This creates an external reference
    ret
MyProc ENDP
```

After assembly, `game.obj` contains:
- Machine code for `MyProc`
- Note that `DrawPixel` is external
- Placeholder for `DrawPixel` address (filled during linking)

### Phase 2: Linking

All `.obj` files are combined into final `.exe`.

**Command Structure**:
```batch
link /SUBSYSTEM:WINDOWS /LIBPATH:%MASMLIBPATH% game.obj blit.obj ...
```

**What Happens**:
1. **Combine**: Merge all object files
2. **Resolve**: Connect external references
3. **Add Libraries**: Include Windows API functions
4. **Create Executable**: Generate final `.exe` with:
   - All machine code
   - Import table (Windows functions)
   - Resource data
   - Startup code

**Example Resolution**:
```
game.obj says: "I need DrawPixel"
blit.obj says: "I have DrawPixel at offset 0x1234"
Linker: "Connecting game.obj's call to blit.obj's DrawPixel"
```

---

## Batch File Syntax

### Basic Commands

#### @echo off
```batch
@echo off
REM Prevents commands from being displayed as they execute
REM @ before echo prevents echo off itself from showing
```

**With echo on**:
```
C:\>echo off
C:\>set VAR=value
C:\>echo Hello
Hello
```

**With @echo off**:
```
Hello
```

#### echo
```batch
echo Hello, World!        REM Print text
echo.                     REM Print blank line
echo %VAR%                REM Print variable value
```

#### set - Variables
```batch
set MYVAR=Hello           REM Create variable
echo %MYVAR%              REM Use variable (outputs: Hello)
set PATH=%PATH%;C:\tools  REM Append to existing variable
```

**Important**: No spaces around `=`
```batch
set VAR=value    ✓ Correct
set VAR = value  ✗ Wrong (spaces included in value)
```

#### REM - Comments
```batch
REM This is a comment
:: This is also a comment (alternative syntax)
```

#### if - Conditionals
```batch
if %errorlevel% neq 0 goto :error
REM If last command failed (error code not 0), jump to :error

if exist file.txt (
    echo File found
) else (
    echo File not found
)
```

**Comparison Operators**:
- `equ` - Equal
- `neq` - Not equal
- `lss` - Less than
- `leq` - Less than or equal
- `gtr` - Greater than
- `geq` - Greater than or equal

#### goto / Labels
```batch
goto :mylabel     REM Jump to :mylabel

:mylabel          REM Define label
echo Jumped here
```

#### pause
```batch
pause
REM Displays: "Press any key to continue..."
REM Waits for user input
```

### Special Variables

#### %errorlevel%
Exit code of last program:
```batch
ml myfile.asm
if %errorlevel% neq 0 (
    echo Compilation failed with code %errorlevel%
)
```

Common error levels:
- `0` - Success
- `1` - General error
- `2` - File not found
- `3` - Path not found

#### %cd%
Current directory:
```batch
echo Current directory: %cd%
```

#### %~dp0
Directory where batch file is located:
```batch
cd %~dp0
REM Change to batch file's directory
```

---

## MASM32 Tools

### ML.EXE - Macro Assembler

Converts Assembly source code to object files.

**Full Syntax**:
```batch
ml [options] filename.asm
```

**Common Options**:

| Option | Description | Example |
|--------|-------------|---------|
| `/c` | Compile only (no link) | `ml /c file.asm` |
| `/coff` | COFF object format (32-bit) | `ml /coff file.asm` |
| `/Cp` | Preserve case in names | `ml /Cp file.asm` |
| `/I<path>` | Include file search path | `ml /IC:\masm32\include file.asm` |
| `/Fo<file>` | Name output object file | `ml /Fomyobj.obj file.asm` |
| `/Fl[file]` | Generate listing file | `ml /Fl file.asm` |
| `/Zi` | Generate debug info | `ml /Zi file.asm` |
| `/W<level>` | Warning level (0-3) | `ml /W2 file.asm` |

**Example Usage**:
```batch
REM Basic compilation
ml /c /coff game.asm

REM With includes and debugging
ml /IC:\masm32\include /Zi /c /coff game.asm

REM Generate listing file
ml /Flgame.lst /c /coff game.asm
```

**Output Files**:
- `.obj` - Object file (always)
- `.lst` - Listing file (with `/Fl`)
- `.pdb` - Debug symbols (with `/Zi`)

### LINK.EXE - Linker

Combines object files and libraries into executable.

**Full Syntax**:
```batch
link [options] objfiles
```

**Common Options**:

| Option | Description | Example |
|--------|-------------|---------|
| `/SUBSYSTEM:WINDOWS` | GUI application | Standard for this project |
| `/SUBSYSTEM:CONSOLE` | Console application | For command-line programs |
| `/LIBPATH:<path>` | Library search path | `/LIBPATH:C:\masm32\lib` |
| `/OUT:<file>` | Output filename | `/OUT:mygame.exe` |
| `/DEBUG` | Include debug info | `/DEBUG` |
| `/MAP` | Generate map file | `/MAP:game.map` |
| `/ENTRY:<symbol>` | Entry point | `/ENTRY:WinMain` |

**Example Usage**:
```batch
REM Basic linking
link /SUBSYSTEM:WINDOWS game.obj blit.obj

REM With libraries and output name
link /SUBSYSTEM:WINDOWS /LIBPATH:C:\masm32\lib /OUT:mygame.exe game.obj blit.obj

REM With debugging and map file
link /SUBSYSTEM:WINDOWS /DEBUG /MAP game.obj blit.obj
```

---

## Troubleshooting

### Common Build Errors

#### Error: 'ml' is not recognized

**Problem**: `ml.exe` not in PATH

**Solutions**:
```batch
REM Option 1: Check MASMPATH variable
echo %MASMPATH%
REM Should show: C:\masm32\bin

REM Option 2: Verify file exists
dir C:\masm32\bin\ml.exe

REM Option 3: Add to PATH manually
set PATH=%PATH%;C:\masm32\bin
```

#### Error: A2008: syntax error

**Problem**: Assembly syntax error in source code

**Solution**:
1. Note the line number from error message
2. Check syntax at that line
3. Common issues:
   - Missing comma between operands
   - Invalid instruction
   - Undefined label

**Example**:
```assembly
; Error
mov eax ebx        ; Missing comma

; Fixed
mov eax, ebx       ; Comma added
```

#### Error: A2006: undefined symbol

**Problem**: Using undefined variable/procedure

**Solutions**:
1. Check spelling
2. Add `EXTERN` declaration if in another file
3. Ensure symbol is defined before use

**Example**:
```assembly
; Error - using before declaration
mov eax, myVar
myVar DWORD 5

; Fixed - declaration before use
myVar DWORD 5
mov eax, myVar

; Or use EXTERN for external symbols
EXTERN DrawPixel:PROC
call DrawPixel
```

#### Error: LNK2001: unresolved external symbol

**Problem**: Linker can't find referenced function/variable

**Solutions**:
1. Ensure all `.obj` files are included in link command
2. Check for typos in function names
3. Verify `PUBLIC` declarations

**Example**:
```assembly
; In blit.asm
DrawPixel PROC
    ; code
    ret
DrawPixel ENDP
PUBLIC DrawPixel    ; Make visible to other files

; In game.asm
EXTERN DrawPixel:PROC
call DrawPixel
```

#### Error: LNK1561: entry point must be defined

**Problem**: No entry point (`WinMain` or `main`) found

**Solution**: Ensure `game.asm` has proper entry point

```assembly
; game.asm should have:
WinMain PROC
    ; initialization
    ret
WinMain END// filepath: c:\Dinosaur Game\docs\Build_System.md
# Build System Documentation

Complete guide to understanding and using the build system for the Dinosaur Game Assembly project.

## Table of Contents
- [Overview](#overview)
- [Build Process](#build-process)
- [Batch File Syntax](#batch-file-syntax)
- [MASM32 Tools](#masm32-tools)
- [Troubleshooting](#troubleshooting)
- [Advanced Topics](#advanced-topics)

---

## Overview

### What is a Build System?

A build system converts human-readable source code into executable programs. For Assembly language:

```
Source Code (.asm) → Assembler → Object Files (.obj) → Linker → Executable (.exe)
```

### Project Build Flow

```
make.bat (Build Script)
    ↓
|---------------------------------|
| COMPILATION PHASE               |
| (Assembler: ml.exe)             |
|---------------------------------|
| stars.asm    → stars.obj        |
| lines.asm    → lines.obj        |
| trig.asm     → trig.obj         |
| blit.asm     → blit.obj         |
| game.asm     → game.obj         |
| bitmaps.asm  → bitmaps.obj      |
|---------------------------------|
    ↓
|---------------------------------|
| LINKING PHASE                   |
| (Linker: link.exe)              |
|---------------------------------|
| Combine all .obj files          |
| Add Windows libraries           |
| Resolve external references     |
| Generate executable             |
|---------------------------------|
    ↓
game.exe (Final Executable)
```

---

## Build Process

### Phase 1: Compilation (Assembly)

Each `.asm` file is assembled into an `.obj` (object) file.

**Command Structure**:
```batch
ml /I%MASMINCPATH% /c /coff /Cp filename.asm
```

**What Happens**:
1. **Parse**: Read Assembly instructions
2. **Translate**: Convert to machine code
3. **Create**: Generate object file with:
   - Machine code
   - Symbol table (function/variable names)
   - Relocation information
   - External references

**Example**:
```assembly
; In game.asm
EXTERN DrawPixel:PROC    ; Reference to function in blit.asm

MyProc PROC
    call DrawPixel       ; This creates an external reference
    ret
MyProc ENDP
```

After assembly, `game.obj` contains:
- Machine code for `MyProc`
- Note that `DrawPixel` is external
- Placeholder for `DrawPixel` address (filled during linking)

### Phase 2: Linking

All `.obj` files are combined into final `.exe`.

**Command Structure**:
```batch
link /SUBSYSTEM:WINDOWS /LIBPATH:%MASMLIBPATH% game.obj blit.obj ...
```

**What Happens**:
1. **Combine**: Merge all object files
2. **Resolve**: Connect external references
3. **Add Libraries**: Include Windows API functions
4. **Create Executable**: Generate final `.exe` with:
   - All machine code
   - Import table (Windows functions)
   - Resource data
   - Startup code

**Example Resolution**:
```
game.obj says: "I need DrawPixel"
blit.obj says: "I have DrawPixel at offset 0x1234"
Linker: "Connecting game.obj's call to blit.obj's DrawPixel"
```

---

## Batch File Syntax

### Basic Commands

#### @echo off
```batch
@echo off
REM Prevents commands from being displayed as they execute
REM @ before echo prevents echo off itself from showing
```

**With echo on**:
```
C:\>echo off
C:\>set VAR=value
C:\>echo Hello
Hello
```

**With @echo off**:
```
Hello
```

#### echo
```batch
echo Hello, World!        REM Print text
echo.                     REM Print blank line
echo %VAR%                REM Print variable value
```

#### set - Variables
```batch
set MYVAR=Hello           REM Create variable
echo %MYVAR%              REM Use variable (outputs: Hello)
set PATH=%PATH%;C:\tools  REM Append to existing variable
```

**Important**: No spaces around `=`
```batch
set VAR=value    ✓ Correct
set VAR = value  ✗ Wrong (spaces included in value)
```

#### REM - Comments
```batch
REM This is a comment
:: This is also a comment (alternative syntax)
```

#### if - Conditionals
```batch
if %errorlevel% neq 0 goto :error
REM If last command failed (error code not 0), jump to :error

if exist file.txt (
    echo File found
) else (
    echo File not found
)
```

**Comparison Operators**:
- `equ` - Equal
- `neq` - Not equal
- `lss` - Less than
- `leq` - Less than or equal
- `gtr` - Greater than
- `geq` - Greater than or equal

#### goto / Labels
```batch
goto :mylabel     REM Jump to :mylabel

:mylabel          REM Define label
echo Jumped here
```

#### pause
```batch
pause
REM Displays: "Press any key to continue..."
REM Waits for user input
```

### Special Variables

#### %errorlevel%
Exit code of last program:
```batch
ml myfile.asm
if %errorlevel% neq 0 (
    echo Compilation failed with code %errorlevel%
)
```

Common error levels:
- `0` - Success
- `1` - General error
- `2` - File not found
- `3` - Path not found

#### %cd%
Current directory:
```batch
echo Current directory: %cd%
```

#### %~dp0
Directory where batch file is located:
```batch
cd %~dp0
REM Change to batch file's directory
```

---

## MASM32 Tools

### ML.EXE - Macro Assembler

Converts Assembly source code to object files.

**Full Syntax**:
```batch
ml [options] filename.asm
```

**Common Options**:

| Option | Description | Example |
|--------|-------------|---------|
| `/c` | Compile only (no link) | `ml /c file.asm` |
| `/coff` | COFF object format (32-bit) | `ml /coff file.asm` |
| `/Cp` | Preserve case in names | `ml /Cp file.asm` |
| `/I<path>` | Include file search path | `ml /IC:\masm32\include file.asm` |
| `/Fo<file>` | Name output object file | `ml /Fomyobj.obj file.asm` |
| `/Fl[file]` | Generate listing file | `ml /Fl file.asm` |
| `/Zi` | Generate debug info | `ml /Zi file.asm` |
| `/W<level>` | Warning level (0-3) | `ml /W2 file.asm` |

**Example Usage**:
```batch
REM Basic compilation
ml /c /coff game.asm

REM With includes and debugging
ml /IC:\masm32\include /Zi /c /coff game.asm

REM Generate listing file
ml /Flgame.lst /c /coff game.asm
```

**Output Files**:
- `.obj` - Object file (always)
- `.lst` - Listing file (with `/Fl`)
- `.pdb` - Debug symbols (with `/Zi`)

### LINK.EXE - Linker

Combines object files and libraries into executable.

**Full Syntax**:
```batch
link [options] objfiles
```

**Common Options**:

| Option | Description | Example |
|--------|-------------|---------|
| `/SUBSYSTEM:WINDOWS` | GUI application | Standard for this project |
| `/SUBSYSTEM:CONSOLE` | Console application | For command-line programs |
| `/LIBPATH:<path>` | Library search path | `/LIBPATH:C:\masm32\lib` |
| `/OUT:<file>` | Output filename | `/OUT:mygame.exe` |
| `/DEBUG` | Include debug info | `/DEBUG` |
| `/MAP` | Generate map file | `/MAP:game.map` |
| `/ENTRY:<symbol>` | Entry point | `/ENTRY:WinMain` |

**Example Usage**:
```batch
REM Basic linking
link /SUBSYSTEM:WINDOWS game.obj blit.obj

REM With libraries and output name
link /SUBSYSTEM:WINDOWS /LIBPATH:C:\masm32\lib /OUT:mygame.exe game.obj blit.obj

REM With debugging and map file
link /SUBSYSTEM:WINDOWS /DEBUG /MAP game.obj blit.obj
```

---

## Troubleshooting

### Common Build Errors

#### Error: 'ml' is not recognized

**Problem**: `ml.exe` not in PATH

**Solutions**:
```batch
REM Option 1: Check MASMPATH variable
echo %MASMPATH%
REM Should show: C:\masm32\bin

REM Option 2: Verify file exists
dir C:\masm32\bin\ml.exe

REM Option 3: Add to PATH manually
set PATH=%PATH%;C:\masm32\bin
```

#### Error: A2008: syntax error

**Problem**: Assembly syntax error in source code

**Solution**:
1. Note the line number from error message
2. Check syntax at that line
3. Common issues:
   - Missing comma between operands
   - Invalid instruction
   - Undefined label

**Example**:
```assembly
; Error
mov eax ebx        ; Missing comma

; Fixed
mov eax, ebx       ; Comma added
```

#### Error: A2006: undefined symbol

**Problem**: Using undefined variable/procedure

**Solutions**:
1. Check spelling
2. Add `EXTERN` declaration if in another file
3. Ensure symbol is defined before use

**Example**:
```assembly
; Error - using before declaration
mov eax, myVar
myVar DWORD 5

; Fixed - declaration before use
myVar DWORD 5
mov eax, myVar

; Or use EXTERN for external symbols
EXTERN DrawPixel:PROC
call DrawPixel
```

#### Error: LNK2001: unresolved external symbol

**Problem**: Linker can't find referenced function/variable

**Solutions**:
1. Ensure all `.obj` files are included in link command
2. Check for typos in function names
3. Verify `PUBLIC` declarations

**Example**:
```assembly
; In blit.asm
DrawPixel PROC
    ; code
    ret
DrawPixel ENDP
PUBLIC DrawPixel    ; Make visible to other files

; In game.asm
EXTERN DrawPixel:PROC
call DrawPixel
```

#### Error: LNK1561: entry point must be defined

**Problem**: No entry point (`WinMain` or `main`) found

**Solution**: Ensure `game.asm` has proper entry point

```assembly
; game.asm should have:
WinMain PROC
    ; initialization
    ret
WinMain END