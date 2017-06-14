function dab_parse_fib1(bytes)
    [nbytes bits_per_bytes] = size(bytes);
    if (nbytes < 1+16+2)
        fprintf(1,'Invalid FIB type 1 - too short (%d bytes)\n', nbytes);
        return;
    end
    charset=dab_binval(bytes(1,1:4));
    OE=dab_binval(bytes(1,5));
    ext=dab_binval(bytes(1,6:8));
    charflag=dab_binval([bytes(nbytes-1,:) bytes(nbytes,:)]);
    fprintf('   FIB1: charset=%d, OE=%d, ext=%d, ',charset, OE, ext);
    
    IDlen=nbytes-(1+16+2);
    if (IDlen > 0)
        IDstart=2;
        fprintf(1,'id=0x');
        for (i=0:IDlen-1)
            IDfieldbyte=dab_binval(bytes(IDstart+i,:));
            fprintf('%02X',IDfieldbyte);
        end
    end
    fprintf(' charflag =0x%04X, Label=', charflag);
    for i=0:15,
        fprintf(1,'%c', dab_binval(bytes(nbytes-2-15+i,:)));
    end
    fprintf(' Abbrv=');
    for i=0:15,
        if (bitand(bitshift(charflag, -15+i),1) == 1)
            fprintf(1,'%c', dab_binval(bytes(nbytes-2-15+i,:)));
        end
    end
    fprintf(1,'\n');
end