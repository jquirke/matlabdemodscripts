function ref_sig = lte_pnseq( cinit, length)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    x1 = zeros(1,1600+length);
    x2 = zeros(1,1600+length);
    
    x1(1) = 1;
    
    for i=0:30,
        x2(i+1) = mod(floor(cinit/(2^i)), 2);
    end
    
    
    for i=1:(1600+length-31),
        x1(i+31) = mod(x1(i+3) + x1(i), 2);
        x2(i+31) = mod(x2(i+3) + x2(i+2) + x2(i+1) + x2(i), 2);
    end
    
    ref_sig=mod(x1(1601:end) + x2(1601:end),2);
end

