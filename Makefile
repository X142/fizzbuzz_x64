# このメイクファイルは、「src」と「obj」フォルダを作り、「src」の中に .asm ファイルを入れた状態で利用されることを想定している
#「obj」フォルダの中に中間生成物が作られる
# 実行ファイルは「main」という名前で生成される

main: obj/fizzbuzz.o obj/DBG.o obj/DBG2.o
	ld -o main $^

obj/%.o: src/%.asm
	nasm -f elf64 $< -o $@

.PHONY: clean
clean:
	@rm -f main
	@rm -f main obj/*
