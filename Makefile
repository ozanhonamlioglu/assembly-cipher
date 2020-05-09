TARGET: cipher

cipher: cipher.o
	ld cipher.o -o cipher

cipher.o: cipher.asm
	nasm -felf64 cipher.asm -o cipher.o

clean:
	rm *.o
	# rm helper.o
	# rm def.o