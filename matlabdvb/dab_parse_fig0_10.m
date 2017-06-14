function dab_parse_fib0_10(bytes)
    [nbytes bits_per_bytes] = size(bytes);

    cn=dab_binval(bytes(1,1));
    oe=dab_binval(bytes(1,2));
    pd=dab_binval(bytes(1,3));
    ext=dab_binval(bytes(1,5));
    if (nbytes < 5)
        fprintf(1,'   FIG0: cn=%d oe=%d pd=%d ext=8 inadequate amount of bytes\n',cn,oe,pd);
        return;
    end
    mju=dab_binval([bytes(2,2:8) bytes(3,:) bytes(4,1:2)]);
    lsi=dab_binval(bytes(4,3));
    confind=dab_binval(bytes(4,4));
    utc=dab_binval(bytes(4,5));
    
    hours=dab_binval([bytes(4,6:8) bytes(5,1:2)]);
    minutes=dab_binval(bytes(5,3:8)); 
    if (utc == 1)
        if (nbytes < 7)
            fprintf(1,'   FIG0: cn=%d oe=%d pd=%d ext=1 inadequate amount of bytes\n');
            return;
        end
        seconds=dab_binval(bytes(6,1:6));
        milliseconds=dab_binval([bytes(6,7:8) bytes(7,:)]);    
    end
    fprintf(1,'   FIG0: cn=%d oe=%d pd=%d ext=8 mju=%d lsi=%d confind=%d utc=%d ', cn, oe,pd,mju,lsi,confind,utc);
    
    if (utc == 1)
        fprintf(1,'time=%d:%d:%d.%d\n', hours,minutes,seconds,milliseconds);
    else
        fprintf(1,'time=%d:%d\n', hours, minutes);
    end
end