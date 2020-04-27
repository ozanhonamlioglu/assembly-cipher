%include "def.asm"
%include "helper.asm"


section .text
global _start

_start:
    printString hello
    printDigit 132
    exitProgram


section .data
    filename: db "secret.txt", 0
    hello: db "Hello World", 10, 0

section .bss
    digitSpace: resb 100 ; RAM den 100 byte veri alanı kiralıyoruz
