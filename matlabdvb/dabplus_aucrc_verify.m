function crcok = dabplus_aucrc_verify(audata, poly)
    n=length(poly)-1;
    reg=ones(1,n);
    if (length(audata)<3)
        crcok = 1;
        return;
    end
    aubody=audata(1:end-2);
    for i=0:length(aubody)*8-1,
        inputbyte=aubody(floor(i/8)+1);
        inputbit=bitand(bitshift(inputbyte,-7+mod(i,8)),1);
        %fprintf('%d',inputbit);
        bit=mod(reg(1)+inputbit,2); % msb^data
        reg(1:n-1)=reg(2:n); %shift left
        reg(n) = 0;
        if (bit == 1)
            reg = mod(reg+poly(2:n+1),2);
        end
    end
    crc=mod(reg+1,2);
    crcbyte(1) = sum(crc(1:8) .* [2^7 2^6 2^5 2^4 2^3 2^2 2^1 2^0]);
    crcbyte(2) = sum(crc(9:16) .* [2^7 2^6 2^5 2^4 2^3 2^2 2^1 2^0]);
    
    crcok= all(audata(end-1:end) == crcbyte);
    
end