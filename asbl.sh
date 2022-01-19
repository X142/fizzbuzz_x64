IFS="." read name ext <<< $1
lstname=dump.lst

nasm -f elf64 -o "${name}.o" -l "$lstname" "$1" -g -F dwarf
ld -m elf_x86_64 -o "$name" "${name}.o"

./$name && objdump -D -M elf_x86_64,intel "$name"
echo ---------------------------------------------------
echo exit code is $?

#objdump -Sd -M elf_x86_64,intel "$name"
# echo "---cat $lstname---"
# cat "$lstname"
