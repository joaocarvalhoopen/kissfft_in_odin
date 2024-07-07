all:
	odin build . -out:kiss_fft.exe --debug

opti:
	odin build . -out:kiss_fft.exe -o:speed

opti_max:	
	odin build . -out:kiss_fft.exe -o:aggressive -microarch:native -no-bounds-check -disable-assert

# Target to build the kissfft optimized static library.
kiss_fft: ./kiss_fft_odin/lib_my_kiss_fft.a

# Rule to create the static library.
./kiss_fft_odin/lib_my_kiss_fft.a: ./kiss_fft_odin/my_kiss_fft.o
	ar rcs ./kiss_fft_odin/lib_my_kiss_fft.a ./kiss_fft_odin/my_kiss_fft.o

# Rule to compile the object file.
# Note : The -ffast-math flag is used to enable fast math optimizations,
#        but I didn t test if the results are correct.
./kiss_fft_odin/my_kiss_fft.o: ./kiss_fft_odin/kiss_fft.c
	clang -c ./kiss_fft_odin/kiss_fft.c -o ./kiss_fft_odin/my_kiss_fft.o -O3 -march=native -funroll-loops
# 	clang -c ./kiss_fft_odin/kiss_fft.c -o ./kiss_fft_odin/my_kiss_fft.o -O3 -march=native -ffast-math -funroll-loops

clean:
	rm kiss_fft.exe
	rm ./kiss_fft_odin/my_kiss_fft.o
	rm ./kiss_fft_odin/lib_my_kiss_fft.a

run:
	./kiss_fft.exe



