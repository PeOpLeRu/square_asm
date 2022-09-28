; —-— macroses code —-—
%macro is_negative 0

mov edx, eax
and edx, 0x80000000
shr edx, 31

%endmacro

%macro push_regs 0 ; save регистров
push eax
push ebx
push ecx
push edx
%endmacro

%macro pop_regs 0 ; load регистров
pop edx
pop ecx
pop ebx
pop eax
%endmacro

%macro print 2 ; выввод на экран
push_regs
mov eax, 4
mov ebx, 1
mov ecx, %1
mov edx, %2
int 0x80
pop_regs
%endmacro

%macro print_digit 0 ; выввод на экран цифры (в string предствлении) лежащей в eax
push_regs
add eax, dword('0')
mov [temp], eax
mov ecx, temp
mov eax, 4
mov ebx, 1
mov edx, 1
int 0x80
pop_regs
%endmacro

%macro print_unsigned 0 ; выввод на экран числа лежащего в eax
push_regs

mov ecx, 10 ; Инициализация делителя
mov ebx, 0 ; Инициализация счетчика цифр числа

%%_div:
mov edx, 0 ; Инициализация старшего разряда делимого
div ecx ; деление
push edx ; save разряда
inc ebx ; Инкремент счетчика цифр числа
cmp eax, 0
jg %%_div

%%_print:
pop eax ; Печать цифры
print_digit
dec ebx
cmp ebx, 0
jg %%_print

pop_regs
%endmacro

%macro print_signed 0 ; выввод на экран отрицательного числа лежащего в eax
push_regs

is_negative
cmp edx, 0
jz %%___print

mov ebx, 0xFFFFFFFF
sub ebx, eax
inc ebx
mov eax, ebx

print minus, 1

%%___print:
print_unsigned

pop_regs
%endmacro

; sqrt(ptr num, ptr destination_res)
%macro sqrt 2   ; Вычисляет корень из 1 параметра и помеащает его во 2 параметр
push_regs

; x1 = num / 2
mov eax, [%1]
mov edx, 0
mov ecx, 2
div ecx
mov [x1], eax ; x1 = num / 2

; x2 = ((num / x1) + x1) / 2
mov edx, 0
mov eax, [%1]
mov ecx, [x1]
div ecx ; x2 = num / x1
add eax, [x1]  ; x2 = (num / x1) + x1
mov [x2], eax
mov edx, 0
mov eax, [x2]
mov ecx, 2
div ecx
mov [x2], eax   ; x2 = ((num / x1) + x1) / 2

; while (x1-x2 >= 1)
%%begin_cycle:
mov eax, [x1]
sub eax, [x2]
cmp eax, 1
jng %%end_cycle

; x1 = x2
mov eax, [x2]
mov [x1], eax  ; x1 = x2

; x2 = ((num / x1) + x1) / 2
mov edx, 0
mov eax, [%1]
mov ecx, [x1]
div ecx ; x2 = num / x1
add eax, [x1]  ; x2 = (num / x1) + x1
mov [x2], eax
mov edx, 0
mov eax, [x2]
mov ecx, 2
div ecx
mov [x2], eax   ; x2 = ((num / x1) + x1) / 2
jmp %%begin_cycle

%%end_cycle:

mov eax, [x2]   ; Ложим результат во 2 параметр
mov [%2], eax

pop_regs
%endmacro

section .text
global _start ; must be declared for linker (ld)

_start: ; tells linker entry point

; —-— main code —-—

sqrt number, res

; Выввод результатов
print begin_res_message, len1

mov eax, [number]
print_unsigned

print end_res_message, len2

mov eax, [res]
print_unsigned

mov eax, 1 ; возврат значения системе
mov ebx, 0
int 0x80

section .data
number dd 4294836225

begin_res_message db "sqrt("
len1 equ $ - begin_res_message
end_res_message db ") = "
len2 equ $ - end_res_message
newline db 0xA, 0xD
len3 equ $ - newline

minus db '-'    ; Используется в print_digit

section .bss
x1 resb 4
x2 resb 4
res resb 4
temp resb 4 ; Используется в print_digit