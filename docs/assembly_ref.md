# Assembly Language Command Reference

A comprehensive guide to x86 Assembly instructions used in this project, designed for beginners learning Assembly language.

## Table of Contents
- [Data Movement](#data-movement)
- [Arithmetic Operations](#arithmetic-operations)
- [Logical Operations](#logical-operations)
- [Comparison & Branching](#comparison--branching)
- [Stack Operations](#stack-operations)
- [Procedure Calls](#procedure-calls)
- [Memory Addressing](#memory-addressing)
- [Bit Manipulation](#bit-manipulation)

---

## Data Movement

### MOV - Move Data
**Syntax**: `MOV destination, source`

Copies data from source to destination. Does NOT modify source.

```assembly
mov eax, 5          ; eax = 5 (immediate value)
mov ebx, eax        ; ebx = eax (register to register)
mov score, eax      ; score = eax (register to memory)
mov eax, score      ; eax = score (memory to register)
```

**Valid Operations**:
- `mov reg, reg`
- `mov reg, memory`
- `mov memory, reg`
- `mov reg, immediate`
- `mov memory, immediate`

**Invalid**: `mov memory, memory` (use register as intermediate)

---

## Arithmetic Operations

### ADD - Addition
**Syntax**: `ADD destination, source`

Adds source to destination, stores result in destination.

```assembly
add eax, 5          ; eax = eax + 5
add score, eax      ; score = score + eax
```

### SUB - Subtraction
**Syntax**: `SUB destination, source`

Subtracts source from destination.

```assembly
sub eax, 3          ; eax = eax - 3
sub obj1x, ebx      ; obj1x = obj1x - ebx
```

### INC - Increment
**Syntax**: `INC destination`

Adds 1 to destination. Faster than `ADD destination, 1`.

```assembly
inc eax             ; eax = eax + 1
inc counter         ; counter++
```

### DEC - Decrement
**Syntax**: `DEC destination`

Subtracts 1 from destination. Faster than `SUB destination, 1`.

```assembly
dec ebx             ; ebx = ebx - 1
dec lives           ; lives--
```

### MUL - Unsigned Multiplication
**Syntax**: `MUL source`

Multiplies AL/AX/EAX by source. Result in AX/DX:AX/EDX:EAX.

```assembly
mov eax, 5
mov ebx, 3
mul ebx             ; eax = 5 * 3 = 15
                    ; High bits in edx (for 64-bit result)
```

### IMUL - Signed Multiplication
**Syntax**: 
- `IMUL source` (like MUL)
- `IMUL destination, source`
- `IMUL destination, source, immediate`

```assembly
imul eax, 4         ; eax = eax * 4
imul ebx, eax, 3    ; ebx = eax * 3
```

### DIV - Unsigned Division
**Syntax**: `DIV divisor`

Divides DX:AX/EDX:EAX by divisor.
- Quotient → AX/EAX
- Remainder → DX/EDX

```assembly
mov eax, 100
mov ebx, 3
mov edx, 0          ; Clear high bits
div ebx             ; eax = 33, edx = 1
```

### NEG - Negate (Two's Complement)
**Syntax**: `NEG destination`

Makes positive numbers negative and vice versa.

```assembly
mov eax, 5
neg eax             ; eax = -5
neg eax             ; eax = 5
```

---

## Logical Operations

### AND - Logical AND
**Syntax**: `AND destination, source`

Performs bitwise AND operation.

```assembly
and eax, 1          ; Check if eax is odd (keeps last bit)
and eax, 0FFh       ; Keep only lower byte
```

### OR - Logical OR
**Syntax**: `OR destination, source`

Performs bitwise OR operation.

```assembly
or eax, 1           ; Set lowest bit to 1
```

### XOR - Logical Exclusive OR
**Syntax**: `XOR destination, source`

Performs bitwise XOR. Useful for clearing registers.

```assembly
xor eax, eax        ; eax = 0 (fast way to clear register)
xor eax, 1          ; Toggle lowest bit
```

### NOT - Logical NOT
**Syntax**: `NOT destination`

Inverts all bits (one's complement).

```assembly
mov al, 0           ; al = 00000000
not al              ; al = 11111111 (255)
```

### TEST - Logical Compare
**Syntax**: `TEST destination, source`

Performs AND without storing result. Sets flags only.

```assembly
test eax, eax       ; Check if eax is zero
jz zero_label       ; Jump if eax was zero
```

---

## Comparison & Branching

### CMP - Compare
**Syntax**: `CMP operand1, operand2`

Subtracts operand2 from operand1 WITHOUT storing result. Sets flags for conditional jumps.

```assembly
cmp eax, 5          ; Compare eax with 5
je equal_label      ; Jump if eax == 5
jl less_label       ; Jump if eax < 5
jg greater_label    ; Jump if eax > 5
```

### Conditional Jumps

#### Equality Jumps
```assembly
JE / JZ             ; Jump if Equal / Zero
JNE / JNZ           ; Jump if Not Equal / Not Zero

cmp eax, ebx
je they_match       ; Jump if eax == ebx
jne different       ; Jump if eax != ebx
```

#### Unsigned Comparisons
```assembly
JA                  ; Jump if Above (>)
JAE                 ; Jump if Above or Equal (>=)
JB                  ; Jump if Below (<)
JBE                 ; Jump if Below or Equal (<=)

cmp eax, 100
ja greater_100      ; Jump if eax > 100 (unsigned)
jbe less_equal_100  ; Jump if eax <= 100 (unsigned)
```

#### Signed Comparisons
```assembly
JG                  ; Jump if Greater (>)
JGE                 ; Jump if Greater or Equal (>=)
JL                  ; Jump if Less (<)
JLE                 ; Jump if Less or Equal (<=)

cmp eax, -5
jl negative         ; Jump if eax < -5 (signed)
jge positive        ; Jump if eax >= -5 (signed)
```

### JMP - Unconditional Jump
**Syntax**: `JMP label`

Always jumps to specified label.

```assembly
jmp end_program     ; Always jump to end_program
```

---

## Stack Operations

### PUSH - Push onto Stack
**Syntax**: `PUSH source`

Pushes value onto stack. ESP decrements by 4.

```assembly
push eax            ; Save eax on stack
push 100            ; Push immediate value
```

### POP - Pop from Stack
**Syntax**: `POP destination`

Pops value from stack into destination. ESP increments by 4.

```assembly
pop ebx             ; Restore ebx from stack
```

**Stack Example**:
```assembly
push eax            ; Save eax
push ebx            ; Save ebx
; ... do something ...
pop ebx             ; Restore ebx
pop eax             ; Restore eax (LIFO - Last In First Out)
```

---

## Procedure Calls

### PROC / ENDP - Define Procedure
**Syntax**: 
```assembly
ProcedureName PROC [USES registers]
    ; code here
    ret
ProcedureName ENDP
```

**USES Directive**: Automatically saves/restores specified registers.

```assembly
MyProc PROC USES eax ebx
    ; eax and ebx automatically pushed at start
    ; and popped before ret
    mov eax, 5
    ret
MyProc ENDP
```

### CALL - Call Procedure
**Syntax**: `CALL procedure_name`

Calls a procedure. Automatically pushes return address.

```assembly
call GameInit       ; Call GameInit procedure
; execution continues here after ret
```

### RET - Return from Procedure
**Syntax**: `RET [value]`

Returns from procedure. Pops return address and jumps to it.

```assembly
MyProc PROC
    mov eax, 100
    ret             ; Return to caller
MyProc ENDP
```

### INVOKE - Call Procedure with Arguments
**Syntax**: `INVOKE procedure, arg1, arg2, ...`

High-level procedure call. Automatically pushes arguments.

```assembly
INVOKE DrawPixel, 10, 20, 255
; Equivalent to:
; push 255
; push 20  
; push 10
; call DrawPixel
```

---

## Memory Addressing

### Direct Addressing
```assembly
mov eax, [score]    ; eax = value at memory location score
mov eax, score      ; Same as above (brackets implied)
```

### Indirect Addressing
```assembly
mov ebx, OFFSET score   ; ebx = address of score
mov eax, [ebx]          ; eax = value at address in ebx
```

### Indexed Addressing
```assembly
mov eax, [ebx + 4]      ; eax = value at (ebx + 4)
mov eax, [ebx + ecx]    ; eax = value at (ebx + ecx)
mov eax, [ebx + ecx*4]  ; eax = value at (ebx + ecx*4)
```

### PTR Operator
Specifies size of memory operand.

```assembly
mov BYTE PTR [eax], 5   ; Store byte (8-bit)
mov WORD PTR [eax], 5   ; Store word (16-bit)
mov DWORD PTR [eax], 5  ; Store double word (32-bit)
```

### OFFSET - Get Address
```assembly
mov ebx, OFFSET variable    ; ebx = address of variable
lea ebx, variable           ; Same as above (Load Effective Address)
```

---

## Bit Manipulation

### SHL / SAL - Shift Left
**Syntax**: `SHL destination, count`

Shifts bits left. Fills with zeros. SAL identical to SHL.

```assembly
mov eax, 5          ; eax = 00000101
shl eax, 1          ; eax = 00001010 (multiply by 2)
shl eax, 2          ; eax = 00101000 (multiply by 4)
```

### SHR - Shift Right (Unsigned)
**Syntax**: `SHR destination, count`

Shifts bits right. Fills with zeros.

```assembly
mov eax, 8          ; eax = 00001000
shr eax, 1          ; eax = 00000100 (divide by 2)
shr eax, 2          ; eax = 00000001 (divide by 4)
```

### SAR - Shift Right (Signed)
**Syntax**: `SAR destination, count`

Shifts bits right. Preserves sign bit.

```assembly
mov eax, -8         ; eax = 11111000 (two's complement)
sar eax, 1          ; eax = 11111100 (still negative)
```

### ROL / ROR - Rotate
**Syntax**: `ROL/ROR destination, count`

Rotates bits left/right (wraps around).

```assembly
mov al, 10010001b
rol al, 1           ; al = 00100011 (left bit wraps to right)
ror al, 1           ; al = 10010001 (back to original)
```

---

## Common Patterns

### Clear Register (Set to Zero)
```assembly
xor eax, eax        ; Fastest way
mov eax, 0          ; Also works but slower
```

### Check if Zero
```assembly
test eax, eax       ; Set flags based on eax
jz is_zero          ; Jump if eax == 0
```

### Absolute Value
```assembly
cmp eax, 0
jge positive
neg eax
positive:
```

### Min/Max
```assembly
; Max of eax and ebx -> eax
cmp eax, ebx
jge already_max
mov eax, ebx
already_max:
```

### Loop Pattern
```assembly
mov ecx, 10         ; Counter
loop_start:
    ; do something
    dec ecx
    jnz loop_start  ; Jump if ecx not zero
```

---

## Register Reference

### General Purpose Registers (32-bit)
- **EAX**: Accumulator (return values, arithmetic)
- **EBX**: Base (pointer to data)
- **ECX**: Counter (loop counter)
- **EDX**: Data (I/O, multiplication/division)
- **ESI**: Source Index (string operations)
- **EDI**: Destination Index (string operations)
- **EBP**: Base Pointer (stack frame)
- **ESP**: Stack Pointer (top of stack) - **DON'T MODIFY DIRECTLY**

### Register Sizes
```assembly
EAX (32-bit)    [        AX (16-bit)        ]
                [ AH (8-bit) ][ AL (8-bit) ]
```

---

## Flags Register

Common flags set by operations:

- **ZF (Zero Flag)**: Set if result is zero
- **SF (Sign Flag)**: Set if result is negative
- **CF (Carry Flag)**: Set if unsigned overflow
- **OF (Overflow Flag)**: Set if signed overflow

```assembly
add al, 200
add al, 100     ; CF=1 (unsigned overflow), OF=1 (signed overflow)
```

---

## Directives

### Data Definition
```assembly
.DATA
    myByte BYTE 5           ; 8-bit
    myWord WORD 1000        ; 16-bit
    myDword DWORD 100000    ; 32-bit
    myString BYTE "Hello", 0
    myArray DWORD 1, 2, 3, 4
```

### Local Variables
```assembly
MyProc PROC
    LOCAL temp:DWORD, count:DWORD
    mov temp, 5
    ret
MyProc ENDP
```

---

## Best Practices

1. **Always initialize registers** before use
2. **Use USES directive** to auto-save registers
3. **Clear EDX before DIV/IDIV** operations
4. **Preserve ESP** (stack pointer)
5. **Match PUSH with POP** (maintain stack balance)
6. **Use meaningful label names**
7. **Comment complex operations**
8. **Check flags after comparisons**

---

## Quick Reference Table

| Operation | Example | Description |
|-----------|---------|-------------|
| Move | `mov eax, 5` | Copy value |
| Add | `add eax, ebx` | eax = eax + ebx |
| Subtract | `sub eax, 5` | eax = eax - 5 |
| Multiply | `imul eax, 3` | eax = eax * 3 |
| Divide | `div ebx` | eax = eax / ebx |
| Compare | `cmp eax, 5` | Set flags |
| Jump if Equal | `je label` | If equal |
| Jump if Not Equal | `jne label` | If not equal |
| Jump if Greater | `jg label` | If greater (signed) |
| Jump if Less | `jl label` | If less (signed) |
| Call Procedure | `call MyProc` | Execute procedure |
| Return | `ret` | Return from procedure |

---

For project-specific implementation details, see [README.md](README.md) and [Developer_Guide.md](Developer_Guide.md).