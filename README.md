# kissfft_in_odin
KISSFFT very fast bindings for the Odin programming language. 

## Description
This are simple but very fast bindings in Odin to the f32 FFT and IFFT of KISS_FFT. The KISS_FFT is a small, fast, and simple FFT library written in C. The trick that makes this bindings so fast is that they are not compiled with GCC, like the KISS_FFT project, but with CLANG, with fast optimization flags. This will do some auto vectorization. The bindings are for the f32 type. The KISS_FFT library is available at it's github page and has a good license. Note that the allocation and dealocation of buffers are made in Odin, but the FFT and IFFT and the creation of the plan are made in C. I made 3 examples of it's usage, and it's very simple to use. In principle this bindings can be used in multithreaded applications. There is also the possibility to speed up the FFT and IFFT by using the CLANG optimization flags ```-ffast-math```. See Makefile. But you should do your own tests to see if it's worth it for your application. The C files present in this lib are from KISSFFT.

## Original GitHub of KISS_FFT 
[https://github.com/mborgerding/kissfft](https://github.com/mborgerding/kissfft)

## To compile this lib do

``` bash
$ make kiss_fft
$ make
$ time ./kissfft.exe

or

$ make kiss_fft
$ make opti_max
$ time ./kissfft.exe
```

## License
The same of KISS_FFT library. BSD-3-Clause

## Have fun!
Best regards, <br>
Joao Carvalho
