%generate the 24,576 point time domain base represenation of PRACH for
%formats 0-3 (need to be cyclic prefix'd etc for the different formats
%later)

%currently only support premable format 0-3
%and unrestricted set (no high speed mode)

function x_u_v_time = gen_prach_seq_base(root_seq, zczc, v, NULRB, NRAPRB, fs_factor)
    
    %find the base sequence
    
    NSCRB = 12; %12 normal subcarriers for non PRACH Frame
    FFTSIZE=2048/fs_factor;
    
    x_u_v = gen_prach_seq(root_seq, zczc, v);
    
    %FFT the result to precode it
    x_u_v_precode = fft(x_u_v);
    
    %now populate the 24,576 point iFFT inputs according to 5.7.3
    
    K=15000/1250 %12, the scaling from 2048point FFT to 24,576 point FFT
    
    phi = 7 ; %subcarrier offset within the 12
    
    k0 = NRAPRB * NSCRB - NULRB*NSCRB/2
        
    startk = phi + K * (k0 + 1/2) %gives us a range from -NDLRB/2 * 12 to +NDRLRB/2*12
    
    startk = startk + FFTSIZE * K / 2 %normalize to the centre of the 24,576 point FFT - this is the DC point
    
    prach_in = zeros(1,FFTSIZE* K);
    
    %edit, i'm thinking the FFTshift might be wrong after all. the results
    %in terms of cyclic subshift correlation are more understandable
    %without it.... TODO - revisit the math and see if it all lines up
    %prach_in(startk+1:1:startk+length(x_u_v_precode)) = fftshift(x_u_v_precode);
    
    %closer look at the formula in 5.7.3 suggests no fftshift is needed.
    %Will confirm experimentally.
    
    prach_in(startk+1:1:startk+length(x_u_v_precode)) = (x_u_v_precode); % we need to fft shift the precoded as well
    
    %move the DC to where matlab FFT expects it (first pos)
    prach_in = fftshift(prach_in);
    
    x_u_v_time = ifft(prach_in);
    
    
    %tests
%     x_u_v_precode2 = prach_extract_freq(0, NULRB, NRAPRB,[zeros(1,3168/fs_factor) x_u_v_time], 2048/fs_factor);
%     
%     diffcode=sum(abs(x_u_v_precode2-x_u_v_precode))
    
end

