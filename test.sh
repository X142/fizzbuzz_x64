nasm -f elf64 DBG.asm
nasm -f elf64 fizzbuzz.asm
ld -m elf_x86_64 -o fizzbuzz fizzbuzz.o DBG.o

./fizzbuzz
