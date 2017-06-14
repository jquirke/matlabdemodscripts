function bitstring = lte_dec_to_binstring( dec, bits )

    powers = fliplr(2.^(0:bits-1));
    
    bitstring = mod(floor(dec./powers), 2);

end

