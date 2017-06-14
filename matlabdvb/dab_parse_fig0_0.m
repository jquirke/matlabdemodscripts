function dab_parse_fig0_0(bytes)
    [nbytes bits_per_bytes] = size(bytes);

    cn=dab_binval(bytes(1,1));
    oe=dab_binval(bytes(1,2));
    pd=dab_binval(bytes(1,3));
    ext=dab_binval(bytes(1,5));
    
    if (nbytes < 5)
        fprintf(1,'   FIG0: cn=%d oe=%d pd=%d ext=0 inadequate amount of bytes\n',cn,oe,pd);
        return;
    end
    country=dab_binval(bytes(2,1:4));
    ensembleid=dab_binval([bytes(2,5:8) bytes(3,:)]);
    chflag=dab_binval(bytes(4,1:2));
    AIflag=dab_binval(bytes(4,3));
    CIFmaj=dab_binval(bytes(4,4:8));
    CIFminor=dab_binval(bytes(5,:));
    
    if (chflag > 0)
        if (nbytes <6)
             fprintf(1,'   FIG0: cn=%d oe=%d pd=%d ext=0 inadequate amount of bytes for change occurrence field\n',cn,oe,pd);
             return;
        end
        occurrence=dab_binval(bytes(6,:));
    end
    fprintf(1,'   FIG0: cn=%d oe=%d pd=%d ext=0 country=%d ensemble=%d chflag=%d AIflag=%d CIFcnt=%d:%03d ',cn,oe,pd,country,ensembleid,chflag,AIflag,CIFmaj,CIFminor);
    if (chflag >0)
        fprintf(1,'occurrence=%d\n', occurrence);
    end
    fprintf(1,'\n');
end
    
            