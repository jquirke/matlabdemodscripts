function bits = dab_int_to_bitvector(value, nbits)
    bitvector=zeros(1,nbits);
    for i=0:nbits-1,
        bitvector(nbits-i) = bitand(bitshift(value,-i), 1);
    end
    bits = bitvector;
end
       