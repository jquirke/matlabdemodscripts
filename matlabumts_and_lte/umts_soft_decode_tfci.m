function tfci = umts_soft_decode_tfci ( encoded_tfci )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    %accumulate the energy in groups of 32
    accum_tfci = zeros(1,32);
    for i = 1:floor(length(encoded_tfci)/32);
        accum_tfci = accum_tfci + encoded_tfci(1+(i-1)*32:32+(i-1)*32);
    end
    
    remainder_bits = mod(length(encoded_tfci),32);
    
    if (remainder_bits > 0)
        accum_tfci(1:remainder_bits) = accum_tfci(1:remainder_bits) + encoded_tfci(floor(length(encoded_tfci)/32)*32+1:end);
    end
    
    max_energy = 0;
    best_tfci = -1;
    for i =0:1023,
        check_tfci = -1+2*umts_encode_tfci(i);
        if (abs(sum(check_tfci .* accum_tfci)) > max_energy)
            best_tfci = i;
            max_energy = abs(sum(check_tfci .* accum_tfci));
        end
    end
    
    tfci = best_tfci;

end

