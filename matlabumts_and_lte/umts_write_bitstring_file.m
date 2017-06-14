function umts_write_bitstring_file( filename, bitstring )

    %pad to 0s
    Nroundedbits = floor((length(bitstring)+7)/8)*8;
    bitstring = [bitstring zeros(1,Nroundedbits - length(bitstring))];
        
    Nbytes = Nroundedbits/8;
    outbuffer = zeros(1,Nbytes);
    for i=1:Nbytes,
        outbuffer(i) = sum( fliplr(2.^[0:7]) .* bitstring((i-1)*8+1:(i-1)*8+8) );
    end 
    
    f=fopen(filename, 'wb');
    fwrite(f,outbuffer, 'uint8');
    fclose(f);

end

