function [d0 d1 d2] = lte_tailbite_enc(bits)
    
    conv_initial_state = bits(1:6);
    trellis = poly2trellis([7], [133 171 165]); 
    codedbits = convenc(bits,trellis, dab_binval(conv_initial_state));
    
    d0 = codedbits(1:3:end);
    d1 = codedbits(2:3:end);
    d2 = codedbits(3:3:end);
    
end
    
        