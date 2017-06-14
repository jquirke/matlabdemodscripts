%pull out the frequency domain of the zadoff chu sequence
function carriers = prach_extract_freq(preamble_format, NULRB, NRAPRB, subframe_or_two_or_three, fftsize)

    NSCRB = 12;
    T_CP_tab = [3168, 21024, 6240, 21024]
    T_CP = T_CP_tab(preamble_format + 1);
    
    fftfactor = 2048/fftsize;
    T_SEQ_tab = [24576, 24576, 2*24576, 2*24576];
    
    T_SEQ = T_SEQ_tab(preamble_format + 1);
    
    fft_in = subframe_or_two_or_three(1+T_CP/fftfactor:1+T_CP/fftfactor+T_SEQ/fftfactor-1);
    
    %combine energy if necessary power if necessary
    
    if (T_SEQ > 24576)
        fft_in(1:24576/fftfactor) = 0.5 * (fft_in(1:24576/fftfactor) + fft_in(24576/fftfactor+1:2*24576/fftfactor));
    end
    
    K=15000/1250; %12, the scaling from 2048point FFT to 24,576 point FFT
    
    phi = 7 ; %subcarrier offset within the 12
    
    k0 = NRAPRB * NSCRB - NULRB*NSCRB/2;
        
    startk = phi + K * (k0 + 1/2) %gives us a range from -NDLRB/2 * 12 to +NDRLRB/2*12
    
    startk = startk + fftsize * K / 2
    
    fft_out = fftshift(fft(fft_in));
    
    carriers = fft_out(startk+1:1:startk+839);

    
end

