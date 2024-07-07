// Bindings name : kissfft_in_odin
//
// Description : This are simple but very fast bindings in Odin to the f32 FFT and IFFT
//               of KISS_FFT.
//               The KISS_FFT is a small, fast, and simple FFT library written in C.
//               The trick that makes this bindings so fast is that they are not compiled
//               with GCC, like the KISS_FFT project, but with CLANG, with fast optimization
//               flags. This will do some auto vectorization.
//               The bindings are for the f32 type.
//               The KISS_FFT library is available at it's github page and has a good license.
//               Note that the allocation and dealocation of buffers are made in Odin, but the
//               FFT and IFFT and the creation of the plan are made in C.
//               I made 3 examples of it's usage, and it's very simple to use.
//               In principle this bindings can be used in multithreaded applications.
//               There is also the possibility to speed up the FFT and IFFT by using the CLANG
//               optimization flags ```-ffast-math````. See make file.
//               But you should do your own tests to see if it's worth it for your application.
//               The C files present in this lib are from KISSFFT.
//
//
// Author of the bindings : Joao Carvalho
// Date                   : 2024-07-07
//
// Original GitHub of KISS_FFT : 
//        https://github.com/mborgerding/kissfft
//
// To compile this lib do:
//
//       $ make kiss_fft
//       $ make
//       $ time ./kissfft.exe
//
//       or
//
//       $ make kiss_fft
//       $ make opti_max
//       $ time ./kissfft.exe
//
//
// License: The same of KISS_FFT library.
//          BSD-3-Clause
//
// Have fun.


package kiss_fft_odin

import "core:fmt"
import "core:strings"
import "core:c"
import "core:c/libc"
import "core:math"
import "core:math/cmplx"

Dir_FFT  :: 0
Dir_IFFT :: 1

// External C object import.
when ODIN_OS == .Linux do foreign import foo { "./lib_my_kiss_fft.a" }

foreign foo {

    // typical usage:      kiss_fft_cfg mycfg = kiss_fft_alloc( 1024, 0, NULL, NULL );
    kiss_fft_alloc :: proc "c" ( nfft : c.int, inverse_fft : c.int, mem : rawptr, lenmem : rawptr ) -> rawptr ---


    // usage: kiss_fft( mycfg, fin, fout );
    //
    // void KISS_FFT_API kiss_fft( kiss_fft_cfg cfg, const kiss_fft_cpx *fin, kiss_fft_cpx *fout );
    kiss_fft :: proc "c" ( cfg : rawptr, buf_in : [ ^ ]complex64, buf_out : [ ^ ]complex64 ) ---
}

apply_ifft_correction_factor :: proc ( vec     : [ ^ ]complex64,
                                       n_elems : c.int           ) {

    for i in 0 ..< n_elems {
        vec[ i ] = vec[ i ] / f32_to_c64( f32( n_elems ), 0.0 )
    }
}


//
// Tests
//

f32_to_c64 :: #force_inline proc ( re, im : f32 ) -> complex64 {

    return complex64( complex( re, im ) )
}

test_kiss_fft :: proc ( ) {

    fmt.printfln( "===>>> test FFT.\n" )

    n_elems_fft : c.int = 1024
    cfg_fft := kiss_fft_alloc( n_elems_fft,
                               Dir_FFT,
                               nil,
                               nil )
    // free the configuration
    defer libc.free( cfg_fft )

    assert( cfg_fft != nil, "Failed to allocate kiss_fft_cfg_fft" )
    
    // Allocate input and output buffers
    buf_in  : [ ^ ]complex64 = make( [ ^ ]complex64, n_elems_fft )
    defer free( buf_in )

    buf_out : [ ^ ]complex64 = make( [ ^ ]complex64, n_elems_fft )
    defer free( buf_out )

    // Fill in buf_in with some data
    for i in 0 ..< n_elems_fft {
        re := math.cos( 2.0 * math.PI * ( f32( i ) / f32(  n_elems_fft / 10 ) ) )
        buf_in[ i ] = f32_to_c64( re, 0.0 )
    }

    // Print the input buffer
    print_vec( "buf_in", buf_in, n_elems_fft)

    // Perform the FFT
    kiss_fft( cfg_fft, buf_in, buf_out );

    // Print the buf_out ( output buffer ).
    print_vec( "buf_out", buf_out, n_elems_fft )

    fmt.printfln( "...end test FFT.\n" )
}

test_kiss_fft_reuse_a_vector :: proc ( ) {

    fmt.printfln( "===>>> test FFT reuse a vector.\n" )

    n_elems_fft : c.int = 16
    cfg_fft := kiss_fft_alloc( n_elems_fft,
                               Dir_FFT,
                               nil,
                               nil )
    // free the configuration
    defer libc.free( cfg_fft )

    assert( cfg_fft != nil, "Failed to allocate kiss_fft_cfg_fft" )
    
    // Allocate input and output buffers
    vec_in  : [ ]complex64 = make( [ ]complex64, n_elems_fft )
    defer delete( vec_in )

    vec_out : [  ]complex64 = make( [ ]complex64, n_elems_fft )
    defer delete( vec_out )

    // Get the raw data from the slices, and make the convertion of types.
    buf_in  : [ ^ ]complex64 = raw_data( vec_in )

    buf_out : [ ^ ]complex64 = raw_data( vec_out )

    // Fill in buf_in with some data
    for i in 0 ..< n_elems_fft {
        re := math.cos( 2.0 * math.PI * ( f32( i ) / f32(  n_elems_fft / 10 ) ) )
        vec_in[ i ] = f32_to_c64( re, 0.0 )
    }

    // Print the input buffer
    print_vec( "buf_in", buf_in, n_elems_fft)

    // Perform the FFT
    kiss_fft( cfg_fft, buf_in, buf_out );

    // Print the buf_out ( output buffer ).
    print_vec( "buf_out", buf_out, n_elems_fft )

    fmt.printfln( "...end test FFT reuse a vector.\n" )
}

print_vec :: proc ( var_name : string,
                    vec      : [ ^ ]complex64,
                    n_elems  : c.int           ) {

    for i in 0 ..< n_elems {
        fmt.printf( "%s[ %d ] = %f + %fi\n",
                    var_name,
                    i,
                    real( vec[ i ] ),
                    imag( vec[ i ] )  )
    }
}

test_kiss_fft_FFT_IFFT :: proc () {

    fmt.printfln( "===>>> test FFT followed by IFFT.\n" )

    n_elems_fft : c.int = 16 // 1024

    //
    // FFT: Fast Fourier Transform
    //

    cfg_fft := kiss_fft_alloc( n_elems_fft,
                               Dir_FFT,
                               nil,
                               nil )
    // Free the configuration.
    defer libc.free( cfg_fft )

    assert( cfg_fft != nil, "Failed to allocate kiss_fft_cfg_fft" )
    
    // Allocate input and output buffers
    buf_original  : [ ]complex64 = make( [ ]complex64, n_elems_fft )
    defer delete( buf_original )

    buf_in  : [ ^ ]complex64 = make( [ ^ ]complex64, n_elems_fft )
    defer free( buf_in )
    
    buf_out : [ ^ ]complex64 = make( [ ^ ]complex64, n_elems_fft )
    defer free( buf_out )

    // Fill in buf_in with some data
    for i in 0 ..< n_elems_fft {
        re := math.cos( 2.0 * math.PI * ( f32( i ) / f32(  n_elems_fft / 3 ) ) )
        // buf_in[ i ]       = f32_to_c64( re, 0.0 )
        // buf_original[ i ] = f32_to_c64( re, 0.0 )
        buf_in[ i ]       = f32_to_c64( re, re )
        buf_original[ i ] = f32_to_c64( re, re )
    }

    // Print the input buffer
    print_vec( "buf_in", buf_in, n_elems_fft )

    // Perform the FFT
    kiss_fft( cfg_fft, buf_in, buf_out );

    // Print the buf_out ( output buffer ).
    print_vec( "buf_out", buf_out, n_elems_fft )


    //
    // IFFT: Inverse Fast Fourier Transform
    //
    
    cfg_ifft := kiss_fft_alloc( n_elems_fft,
                                Dir_IFFT,
                                nil,
                                nil )
    // Free the configuration.
    defer libc.free( cfg_ifft )

    assert( cfg_ifft != nil, "Failed to allocate kiss_fft_cfg_ifft" )

    // Perform the IFFT
    kiss_fft( cfg_ifft, buf_out, buf_in );

    // Print the buf_in ( output buffer ).
    print_vec( "buf_in_that_is_ouput", buf_in, n_elems_fft )

    // Apply the correction factor.
    apply_ifft_correction_factor( buf_in, n_elems_fft )

    // Check if the original and the IFFT are the same.
    for i in 0 ..< n_elems_fft {
        fmt.printfln( "buf_original[ %d ] = %f + %fi  buf_in[ %d ] = %f + %fi\n",
                      i,
                      real( buf_original[ i ] ),
                      imag( buf_original[ i ] ),
                      i,
                      real( buf_in[ i ] ),
                      imag( buf_in[ i ] ) )

        assert( cmplx.abs( buf_original[ i ] - buf_in[ i ] ) < 0.0001, "IFFT failed" )
    }

    fmt.printfln( "...end test FFT followed by IFFT PASSED.\n" )
}

