function fireok = dabplus_checksync_quickly(audiosuperframe)
    firepoly = [1 0 1 1 1 1 0 0 0 0 0 1 0 1 1 1 1];
    nbytes = length(audiosuperframe);
    inputbits=zeros(1,nbytes*8);
    for i=1:nbytes,
        inputbits((i-1)*8+1:(i-1)*8+8) = dab_int_to_bitvector(audiosuperframe(i),8);
    end

    fire = inputbits(1:16);
    fireinput = inputbits(17:17+9*8-1);
    firecheck=dabplus_firecheck(fireinput, firepoly);
    fireok = sum(abs(firecheck - fire)) == 0;
    
end