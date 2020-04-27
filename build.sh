#!/bin/sh

NAME=cipher
INCLUDE_FILE=helper

nasm -felf64 $NAME.asm # -p $INCLUDE_FILE.asm
ld $NAME.o -o $NAME

./$NAME