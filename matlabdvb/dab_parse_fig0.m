function dab_parse_fig0(bytes)
    [nbytes bits_per_bytes] = size(bytes);
    if (nbytes < 1)
        fprintf(1,'Invalid FIG type 0 - too short (%d bytes)\n', nbytes);
    end
    
    cn=dab_binval(bytes(1,1));
    oe=dab_binval(bytes(1,2));
    pd=dab_binval(bytes(1,3));
    ext=dab_binval(bytes(1,4:8));
    
    switch (ext)
        case 0
            dab_parse_fig0_0(bytes);
        case 1
            dab_parse_fig0_1(bytes);
        case 2
            dab_parse_fig0_2(bytes);
        case 3
            dab_parse_fig0_3(bytes);
        case 5
            dab_parse_fig0_5(bytes);
        case 10
            dab_parse_fig0_10(bytes);
        case 14
            dab_parse_fig0_14(bytes);
        otherwise
            fprintf(1,'   FIG0: cn=%d oe=%d pd=%d unknown extension %d\n', cn, oe, pd, ext);
    end
end