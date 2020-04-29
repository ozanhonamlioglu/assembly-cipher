%include "def.asm"
%include "helper.asm"

section .text
global _start

_start:
    encrypte
    exitProgram

section .data
    filename: db "secret.txt", 0

section .bss
    digitSpace: resb 100 ; RAM den 100 byte veri alanı kiralıyoruz
    crypetedString: resb 100 ; RAM den 100 byte veri alanı kiralıyoruz
    lengthOfCryptedString: resb 1

; In this example
; I print digits to the screen without giving a length to them
; I print strings to the screen without giving a length to them
; I worked with arguments from command line
; I used file operations Write/Read etc.